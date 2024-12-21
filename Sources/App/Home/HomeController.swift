import Hummingbird

struct HomeController {
    typealias Context = AppRequestContext

    var routes: RouteCollection<Context> {
        RouteCollection(context: Context.self)
            .on("/", method: .get, use: home)
            .on("/", method: .post, use: signin)
            .on("/lobby", method: .get, use: lobby)
            .on("/signout", method: .post, use: signout)
    }

    @Sendable func home(request: Request, context: Context) async throws -> Response {
        if let id = context.session?.id {
            let path = await context.app.lobby.gamePath(for: id)
            return Response.redirect(to: path ?? "/lobby")
        }

        let name = request.uri.queryParameters["name"].map { String($0) } ?? request.cookies["name"]?.value
        let returnTo = request.uri.queryParameters["returnTo"].map { String($0) }
        let headers: HTTPFields = [ .contentType: "text/html; charset=utf-8" ]
        return Response(status: .ok, headers: headers, body: .markup {
            SigninPage(name: name, returnTo: returnTo)
        })
    }

    @Sendable func signin(request: Request, context: Context) async throws -> Response {
        let form = try await request.decode(as: SigninFormData.self, context: context)
        let session = await context.app.sessions.add(Session(name: form.name))
        await context.app.lobby.add(session)
        context.logger.info("Player signed in", metadata: [
            "name": .string(session.name),
            "id": .string(session.idBase36),
        ])

        var response = Response.redirect(to: "/lobby")
        if let returnTo = form.returnTo, !returnTo.hasPrefix("//"), !returnTo.contains(":") {
            response = Response.redirect(to: returnTo)
        }
        response.setCookie(Cookie(name: "name", value: session.name))
        response.setCookie(Cookie(name: Session.cookieName, value: session.idBase36))
        return response
    }

    @Sendable func signout(request: Request, context: Context) async throws -> Response {
        if let session = context.session {
            await context.app.sessions.remove(session.id)
            context.logger.info("Player signed out", metadata: [
                "name": .string(session.name),
                "id": .string(session.idBase36),
            ])
        }

        var response = Response.redirect(to: "/")
        response.setCookie(Cookie(name: Session.cookieName, value: "", expires: .distantPast))
        return response
    }

    @Sendable func lobby(request: Request, context: Context) async throws -> Response {
        guard let session = context.session else { return Response.redirect(to: "/?returnTo=%2Flobby") }
        return try await request.negotiate(context: context) { type in
            switch type ?? .textHtml {

            case MediaType(type: .text, subType: "event-stream"):
                if let path = await context.app.lobby.gamePath(for: session.id) {
                    let event = context.app.lobby.event("redirect", data: path)
                    let body = ResponseBody(byteBuffer: ByteBuffer(string: event))
                    return Response(status: .ok, headers: .eventStream, body: body)
                }

                await context.app.lobby.add(session)
                let stream = await context.app.lobby.stream.map(ByteBuffer.init(string:)).cancelOnGracefulShutdown()
                return Response(status: .ok, headers: .eventStream, body: ResponseBody(asyncSequence: stream))

            case .textHtml:
                if let path = await context.app.lobby.gamePath(for: session.id) { return Response.redirect(to: path) }

                await context.app.lobby.add(session)
                let players = await context.app.lobby.players
                let headers: HTTPFields = [
                    .cacheControl: "no-store", .vary: "accept",
                    .contentType: "text/html; charset=utf-8",
                ]
                return Response(status: .ok, headers: headers, body: .markup {
                    LobbyPage(name: session.name, players: players)
                })

            default:
                return nil
            }
        }
    }

    struct SigninFormData: Codable {
        let name: String
        let returnTo: String?
    }
}
