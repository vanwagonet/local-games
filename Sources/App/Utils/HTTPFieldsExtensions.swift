import Hummingbird

extension HTTPFields {
    static var eventStream: HTTPFields {
        [
            .cacheControl: "no-store",
            .connection: "keep-alive",
            .contentType: "text/event-stream",
            .vary: "accept",
        ]
    }
}
