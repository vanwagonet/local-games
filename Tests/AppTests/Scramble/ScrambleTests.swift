import Foundation
import Testing

@testable import App

@Suite
struct ScrambleTests {
    typealias Board = Scramble.Board
    typealias Position = Scramble.Position

    @Test(arguments: [ Scramble.Size.four, .five ])
    func dice(_ size: Scramble.Size) throws {
        let board = Scramble.randomBoard(size: size)
        #expect(board.count == size.rawValue)
        for i in 0..<size.rawValue {
            #expect(board[i].count == size.rawValue)
        }
        // print(board.map { $0.joined(separator: " ") } .joined(separator: "\n"))
    }

    @Test(.disabled(), arguments: [ Scramble.Size.four, .five ])
    func count(_ size: Scramble.Size) async throws {
        let game = Scramble(id: .random, players: [], size: size)
        var count = 0
        for try await word in URL(filePath: "public/scramble-words.txt").lines {
            if await !game.paths(for: word).isEmpty { count += 1 }
        }
        // print(count)
        #expect(count > 10)
    }

    @Test func paths() async throws {
        let game = Scramble(board: [ [ "B", "At" ], [ "A", "T" ] ], id: .random, players: [])
        #expect(await game.paths(for: "bat") == [
            [ Position(x: 0, y: 0), Position(x: 1, y: 0) ],
            [ Position(x: 0, y: 0), Position(x: 0, y: 1), Position(x: 1, y: 1) ],
        ])
        #expect(await game.paths(for: "tab") == [
            [ Position(x: 1, y: 1), Position(x: 0, y: 1), Position(x: 0, y: 0) ],
        ])
    }
}
