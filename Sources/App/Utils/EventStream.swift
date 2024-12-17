import AsyncAlgorithms
import Hummingbird
import Logging

protocol EventStream: Actor {
    typealias StreamID = Identifier<Self, UInt>
    typealias Streams = [StreamID: AsyncStream<String>.Continuation]

    var heartbeat: Task<Void, Never>? { get set }
    var logger: Logger { get }
    var streams: Streams { get set }

    func onConnected(_ stream: AsyncStream<String>.Continuation)
}

extension EventStream {
    func onConnected(_ stream: AsyncStream<String>.Continuation) {}

    func notify(_ data: String) {
        for (id, stream) in streams {
            if case .terminated = stream.yield(data) { cleanup(id) }
            logger.debug("Notified", metadata: [ "id": .string(id.base36) ])
        }
    }

    func notify(event: String, data: String) {
        notify(self.event(event, data: data))
    }

    nonisolated func event(data: String) -> String {
        "data: \(data.replacingOccurrences(of: "\n", with: "\ndata: "))\n\n"
    }

    nonisolated func event(_ name: String, data: String) -> String {
        "event: \(name)\ndata: \(data.replacingOccurrences(of: "\n", with: "\ndata: "))\n\n"
    }

    private func setup(_ stream: AsyncStream<String>.Continuation) {
        let id = StreamID.next(avoiding: streams.keys)
        logger.info("Connected", metadata: [ "id": .string(id.base36) ])
        streams[id] = stream
        stream.onTermination = { [weak self] _ in Task { await self?.cleanup(id) } }
        onConnected(stream)
        if heartbeat == nil {
            heartbeat = Task { [weak self] in
                for await _ in AsyncTimerSequence.repeating(every: .seconds(20)).cancelOnGracefulShutdown() {
                    await self?.notify(event: "ping", data: "")
                }
            }
            logger.info("Started heartbeat")
        }
    }

    private func cleanup(_ id: StreamID) {
        streams.removeValue(forKey: id)
        logger.info("Disconnected", metadata: [ "id": .string(id.base36) ])
        if streams.isEmpty {
            heartbeat?.cancel()
            heartbeat = nil
            logger.info("Cancelled heartbeat")
        }
    }

    var stream: AsyncStream<String> {
        AsyncStream { self.setup($0) }
    }
}
