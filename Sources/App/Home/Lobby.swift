import Logging

final actor Lobby: EventStream {
    var heartbeat: Task<Void, Never>?
    let logger = Logger(label: "Lobby")
    var playerIDs: Set<Session.ID> = [] { didSet { Task { await notify(playersEvent) } } }
    let sessions: SessionStorage
    var streams: Streams = [:]

    var scrambles: [Scramble.ID: Scramble] = [:]

    init(sessions: SessionStorage) {
        self.sessions = sessions
    }

    deinit {
        heartbeat?.cancel()
        for (_, stream) in streams { stream.finish() }
    }

    func add(_ session: Session) async {
        playerIDs.insert(session.id)
    }

    var players: [String] {
        get async { await sessions[for: playerIDs].map(\.name) }
    }

    func onConnected(_ stream: AsyncStream<String>.Continuation) {
        Task { _ = await stream.yield(self.playersEvent) }
    }

    var playersEvent: String {
        get async { await event(data: LobbyPage.PlayerList(players: players).render()) }
    }

    func gamePath(for id: Session.ID) async -> String? {
        guard !playerIDs.contains(id) else { return nil }
        if let game = await scramble(for: id), await game.remaining > .zero {
            return Scramble.path(game.id)
        }
        return nil
    }
}
