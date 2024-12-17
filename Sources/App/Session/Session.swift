struct Session: Identifiable {
    let id: Identifier<Session, UInt>
    let name: String

    static let cookieName = "session"

    init(name: String) {
        self.id = Identifier(rawValue: .zero)
        self.name = name
    }

    init(id: ID, _ source: Session) {
        self.id = id
        self.name = source.name
    }

    var idBase36: String { String(id.rawValue, radix: 36) }
}
