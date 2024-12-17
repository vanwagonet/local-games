struct AppContext: Sendable {
    let lobby: Lobby
    let sessions: SessionStorage

    static let `default` = AppContext()

    private init() {
        let storage = SessionStorage()
        lobby = Lobby(sessions: storage)
        sessions = storage
    }
}
