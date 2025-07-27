actor Scramble: Identifiable {
    let board: Board
    let duration = Duration.minutes(3)
    var entries: [Session.ID: [Entry]]
    nonisolated let id: Identifier<Scramble, UInt>
    var players: Set<Session.ID> { Set(entries.keys) }
    let start: ContinuousClock.Instant

    var remaining: Duration { max(start.advanced(by: duration) - .now, .zero) }
    static let path = "/scramble"
    static func path(_ id: ID) -> String { "\(path)/\(id.base36)" }

    init(board: Board, id: ID, players: Set<Session.ID>, start: ContinuousClock.Instant = .now + .seconds(3)) {
        self.board = board
        self.entries = Dictionary(uniqueKeysWithValues: players.map { ($0, []) })
        self.id = id
        self.start = start
    }

    init(id: ID, players: Set<Session.ID>, size: Size, start: ContinuousClock.Instant = .now + .seconds(3)) {
        self.init(board: Scramble.randomBoard(size: size), id: id, players: players, start: start)
    }

    func addEntry(_ word: String, inDict: Bool, from id: Session.ID) {
        guard remaining > .zero else { return }
        let word = word.lowercased()
        guard word.count >= 3, let player = entries[id], player.allSatisfy({ $0.word != word }) else { return }
        var entry = Entry(
            inDict: inDict,
            paths: paths(for: word),
            word: word
        )
        for (playerID, player) in entries {
            for (i, other) in player.enumerated() where other.word == word {
                entries[playerID]?[i].alsoFoundBy.insert(id)
                entry.alsoFoundBy.insert(playerID)
            }
        }
        entries[id]?.append(entry)
        entries[id]?.sort { $0.word < $1.word }
    }

    func paths(for word: String) -> [[Position]] {
        var paths: [[Position]] = []
        for (y, row) in board.enumerated() {
            for (x, die) in row.enumerated() where prefix(die, matches: word) {
                paths.append(contentsOf: self.paths(
                    for: word.dropFirst(die.count),
                    after: [ Position(x: x, y: y) ]
                ))
            }
        }
        return paths
    }

    func paths(for remainder: Substring, after path: [Position] = []) -> [[Position]] {
        guard let last = path.last, !remainder.isEmpty else { return [ path ] }

        var paths: [[Position]] = []
        for (y, row) in board.enumerated() where abs(y - last.y) <= 1 {
            for (x, die) in row.enumerated() where abs(x - last.x) <= 1 {
                if prefix(die, matches: remainder), !path.contains(Position(x: x, y: y)) {
                    paths.append(contentsOf: self.paths(
                        for: remainder.dropFirst(die.count),
                        after: path + [ Position(x: x, y: y) ]
                    ))
                }
            }
        }
        return paths
    }

    func prefix<S: StringProtocol>(_ prefix: Substring, matches remainder: S) -> Bool {
        remainder.prefix(prefix.count).compare(
            prefix,
            options: [ .caseInsensitive, .diacriticInsensitive, .widthInsensitive ],
        ) == .orderedSame
    }

    func state(for id: Session.ID) -> State {
        State(board: board, duration: duration, entries: entries[id] ?? [], gameID: self.id, remaining: remaining)
    }

    func quit(_ id: Session.ID) {
        entries.removeValue(forKey: id)
    }

    typealias Board = [[Substring]]
    typealias Path = [Position]

    struct Entry {
        var alsoFoundBy: Set<Session.ID> = []
        let inDict: Bool
        let paths: [Path]
        let word: String
    }

    struct Position: Hashable {
        let x: Int
        let y: Int
    }

    enum Size: Int, Codable {
        case four = 4
        case five = 5
    }

    struct State {
        let board: Board
        let duration: Duration
        let entries: [Entry]
        let gameID: Scramble.ID
        let remaining: Duration
    }
}

extension Scramble {
    static func randomBoard(size: Size) -> Board {
        switch size {
        case .four: randomBoard4()
        case .five: randomBoard5()
        }
    }

    static func randomBoard5() -> Board {
        let distribution: [Substring: Double] = [
            "A": 0.082,
            "B": 0.015,
            "C": 0.028,
            "D": 0.043,
            "E": 0.027, // 0.127, but it's the backup, and getting all this to exactly add up to 1 is hard.
            "F": 0.022,
            "G": 0.02,
            "H": 0.061,
            "I": 0.07,
            "J": 0.002,
            "K": 0.008,
            "L": 0.04,
            "M": 0.024,
            "N": 0.067,
            "O": 0.075,
            "P": 0.019,
            "Qu": 0.001,
            "R": 0.06,
            "S": 0.063,
            "T": 0.091,
            "U": 0.028,
            "V": 0.0098,
            "W": 0.024,
            "X": 0.0015,
            "Y": 0.02,
            "Z": 0.001,
            "An": 0.005,
            "Er": 0.005,
            "He": 0.005,
            "In": 0.005,
            "Th": 0.005,
        ]
        return (0..<5).map { _ in
            (0..<5).map { _ in
                let mark = Double.random(in: 0..<1)
                var current = Double.zero
                for (face, percent) in distribution {
                    current += percent
                    if mark <= current { return face }
                }
                return "E" // Purposely left a ~10% chance of getting here to ensure other letters get a fair shot.
            }
        }
    }

    static func randomBoard4() -> Board {
        let side = 4
        let total = side * side
        let dice = """
            A A E E G N
            A B B J O O
            A C H O P S
            A F F K P S
            A O O W T T
            C I M O T U
            D E I L R X
            D E L R V Y
            D I S T T Y
            E E G H N W
            E E I N S U
            E H R T V W
            E I O S S T
            E L T T R Y
            H I M N Qu U
            H L N N R Z

            A A E E G N
            A C H O P S
            A F F K P S
            D E I L R X
            D E L R V Y
            E E G H N W
            E I O S S T
            H I M N Qu U
            H L N N R Z
            """
            .split(separator: "\n")
            .prefix(total)
            .compactMap { $0.split(separator: " ").randomElement() }
            .shuffled()
        return stride(from: 0, to: total, by: side).map {
            Array(dice[$0..<min($0 + side, total)])
        }
    }
}

extension Scramble.Entry {
    var isValid: Bool {
        alsoFoundBy.isEmpty && inDict && !paths.isEmpty
    }

    var score: Int {
        isValid ? value : 0
    }

    var value: Int {
        1 << (word.count - 3)
    }
}
