import Hummingbird

struct ScrambleController {
    typealias Context = AppRequestContext

    var routes: RouteCollection<Context> {
        RouteCollection(context: Context.self)
            .on("/", method: .post, use: start)
            .on("/:id", method: .get, use: game)
            .on("/:id/entries", method: .post, use: addEntry)
    }

    @Sendable func start(request: Request, context: Context) async throws -> Response {
        guard let session = context.session, await context.app.lobby.playerIDs.contains(session.id) else {
            throw HTTPError(.notFound)
        }

        return await Response.redirect(to: context.app.lobby.startScramble())
    }

    @Sendable func game(request: Request, context: Context) async throws -> Response {
        guard let param = context.parameters.get("id", as: String.self),
              let id = Scramble.ID(base36: param), let game = await context.app.lobby.scrambles[id],
              let session = context.session, await game.players.contains(session.id) else {
            return Response.redirect(to: "/lobby")
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

    struct EntryFormData: Codable {
        let word: String
    }
}
