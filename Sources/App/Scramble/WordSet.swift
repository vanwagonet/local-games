import Foundation
import Logging

actor WordSet {
    private let logger = Logger(label: "WordSet")
    private var task: Task<Void, Error>?
    private var words: Set<String> = []

    static let shared = WordSet()

    private init() {}

    func contains(_ word: String) -> Bool { words.contains(word.lowercased()) }

    func load() async throws {
        guard words.isEmpty else { return }
        for try await word in URL(filePath: "public/scramble-words.txt").lines {
            words.insert(word)
        }
        logger.info("Loaded \(words.count.formatted()) words")
    }
}
