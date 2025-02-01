import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import App

@Suite
struct AppTests {
    struct TestArguments: AppArguments {
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    @Test func signin() async throws {
        try await buildApplication(TestArguments()).test(.router) { client in
            var response = try await client.execute(uri: "/", method: .get)
            #expect(response.body == ByteBuffer(string: SigninPage().render()))

            response = try await client.execute(
                uri: "/",
                method: .post,
                headers: [ .contentType: MediaType.applicationUrlEncoded.description ],
                body: ByteBuffer(string: "name=Bob")
            )
            #expect(response.headers[.location] == Lobby.path)

            let setCookie = try #require(response.headers[.setCookie])
            let cookie = try String(#require(/(session=[a-z0-9]+); HttpOnly/.firstMatch(in: setCookie)?.output.1))

            response = try await client.execute(uri: Lobby.path, method: .get, headers: [ .cookie: cookie ])
            #expect(response.body == LobbyPage(name: "Bob", players: [ "Bob" ]).render())
        }
    }
}
