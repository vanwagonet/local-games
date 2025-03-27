actor Scramble: Identifiable {
    let board: Board
    var entries: [Session.ID: [Entry]]
    nonisolated let id: Identifier<Scramble, UInt>
    var players: Set<Session.ID> { Set(entries.keys) }
    let start: ContinuousClock.Instant

    var remaining: Duration { max(start.advanced(by: .minutes(3)) - .now, .zero) }
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
        var expectU = false
        for char in word.uppercased() {
            if char == "U", expectU {
                expectU = false
            } else if expectU {
                return []
            } else {
                paths = find(char, after: paths)
                if paths.isEmpty { break }
                if char == "Q" { expectU = true }
            }
        }
        return paths
    }

    func find(_ char: Character) -> [[Position]] {
        var paths: [[Position]] = []
        for (y, row) in board.enumerated() {
            for (x, die) in row.enumerated() where die.first == char {
                paths.append([ Position(x: x, y: y) ])
            }
        }
        return paths
    }

    func find(_ char: Character, after paths: [[Position]]) -> [[Position]] {
        guard !paths.isEmpty else { return find(char) }
        var next: [[Position]] = []
        for path in paths {
            guard let last = path.last else { continue }
            for (y, row) in board.enumerated() where abs(y - last.y) <= 1 {
                for (x, die) in row.enumerated() where abs(x - last.x) <= 1 {
                    if die.first == char, !path.contains(Position(x: x, y: y)) {
                        next.append(path + [ Position(x: x, y: y) ])
                    }
                }
            }
        }
        return next
    }

    func state(for id: Session.ID) -> State {
        State(board: board, entries: entries[id] ?? [], gameID: self.id, remaining: remaining)
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
        let entries: [Entry]
        let gameID: Scramble.ID
        let remaining: Duration
    }
}

extension Scramble {
    static func randomBoard(size: Size) -> Board {
        let side = size.rawValue
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
