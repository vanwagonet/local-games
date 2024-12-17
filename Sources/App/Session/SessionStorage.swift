final actor SessionStorage {
    var sessions: [Session.ID: Session] = [:]

    subscript(_ id: Session.ID) -> Session? { sessions[id] }

    subscript<S>(for ids: S) -> [Session]
    where S: Sequence, S.Element == Session.ID {
        ids.compactMap { sessions[$0] }
    }

    subscript(cookie cookie: String) -> Session? {
        guard let id = Session.ID(base36: cookie) else { return nil }
        return sessions[id]
    }

    func add(_ session: Session) -> Session {
        var session = session
        if session.id.rawValue == .zero {
            session = Session(id: .next(avoiding: sessions.keys), session)
        }
        sessions[session.id] = session
        return session
    }

    func remove(_ id: Session.ID) {
        sessions.removeValue(forKey: id)
    }
}
