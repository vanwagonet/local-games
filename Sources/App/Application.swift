import Hummingbird
import Logging

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()
    return Application(
        router: buildRouter(),
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "LocalGames"
        ),
        logger: {
            var logger = Logger(label: "LocalGames")
            logger.logLevel =
                arguments.logLevel ??
                environment.get("LOG_LEVEL").flatMap { Logger.Level(rawValue: $0) } ??
                .info
            return logger
        }()
    )
}
