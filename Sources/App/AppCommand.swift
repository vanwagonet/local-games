import ArgumentParser
import Hummingbird
import Logging

@main
struct AppCommand: AsyncParsableCommand, AppArguments {
    @Option(name: .shortAndLong)
    var hostname: String = "0.0.0.0"

    @Option(name: .shortAndLong)
    var port: Int = 8888

    @Option(name: .shortAndLong)
    var logLevel: Logger.Level?

    func run() async throws {
        try await WordSet.shared.load()
        let app = try await buildApplication(self)
        try await app.runService()
    }
}

/// Extend `Logger.Level` so it can be used as an argument
#if hasFeature(RetroactiveAttribute)
    extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
    extension Logger.Level: ExpressibleByArgument {}
#endif
