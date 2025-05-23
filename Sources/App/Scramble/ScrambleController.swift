import Hummingbird

struct ScrambleController {
    typealias Context = AppRequestContext

    var routes: RouteCollection<Context> {
        RouteCollection(context: Context.self)
            .on("/", method: .post, use: start)
            .on("/:id", method: .get, use: game)
            .on("/:id/entries", method: .post, use: addEntry)
            .on("/:id/quit", method: .post, use: quit)
    }

    @Sendable func start(request: Request, context: Context) async throws -> Response {
        guard let session = context.session else { return Response.redirect(to: "/") }
        guard await context.app.lobby.playerIDs.contains(session.id) else {
            if let gameID = await context.app.lobby.scramble(for: session.id)?.id {
                return Response.redirect(to: Scramble.path(gameID))
            }
            return Response.redirect(to: Lobby.path)
        }

        let size = try await request.decode(as: StartFormData.self, context: context).size
        return await Response.redirect(to: context.app.lobby.startScramble(size: size))
    }

    @Sendable func game(request: Request, context: Context) async throws -> Response {
        guard let param = context.parameters.get("id", as: String.self),
              let id = Scramble.ID(base36: param), let game = await context.app.lobby.scrambles[id],
              let session = context.session, await game.players.contains(session.id) else {
            return Response.redirect(to: Lobby.path)
        }

        let players = await context.app.sessions[for: game.players]
        let state = await game.state(for: session.id)
        let headers: HTTPFields = [ .cacheControl: "no-store", .contentType: "text/html; charset=utf-8" ]
        return Response(status: .ok, headers: headers, body: .markup {
            ScramblePage(players: players, state: state)
        })
    }

    @Sendable func addEntry(request: Request, context: Context) async throws -> Response {
        guard let param = context.parameters.get("id", as: String.self),
              let id = Scramble.ID(base36: param), let game = await context.app.lobby.scrambles[id],
              let session = context.session, await game.players.contains(session.id) else {
            throw HTTPError(.notFound)
        }

        let form = try await request.decode(as: EntryFormData.self, context: context)
        await game.addEntry(form.word, inDict: WordSet.shared.contains(form.word), from: session.id)
        return Response.redirect(to: Scramble.path(id))
    }

    @Sendable func quit(request: Request, context: Context) async throws -> Response {
        guard let param = context.parameters.get("id", as: String.self),
              let id = Scramble.ID(base36: param), let game = await context.app.lobby.scrambles[id],
              let session = context.session, await game.players.contains(session.id) else {
            return Response.redirect(to: Lobby.path)
        }
        await game.quit(session.id)
        return Response.redirect(to: Lobby.path)
    }

    struct StartFormData: Codable {
        let size: Scramble.Size
    }

    struct EntryFormData: Codable {
        let word: String
    }
}
