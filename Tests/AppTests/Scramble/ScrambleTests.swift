import Testing

@testable import App

@Suite
struct ScrambleTests {
    @Test(arguments: [ Scramble.Size.four, .five ])
    func dice(_ size: Scramble.Size) throws {
        let board = Scramble.randomBoard(size: size)
        #expect(board.count == size.rawValue)
        for i in 0..<size.rawValue {
            #expect(board[i].count == size.rawValue)
        }
        #expect(board.allSatisfy { $0.allSatisfy { $0.count == 1 || $0 == "Qu" } })
        // print(board.map { $0.joined(separator: " ") } .joined(separator: "\n"))
    }
}
