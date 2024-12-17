import Elementary

struct LobbyPage: HTMLDocument {
    var name: String
    var players: [String]

    let title = "Local Games"
    let lang = "en"

    var head: some HTML {
        meta(.charset(.utf8))
        meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
        link(.href("/icon.svg"), .rel(.icon))
        noscript { meta(.httpEquiv("refresh"), .content("5")) }
        link(.href("/style.css"), .rel(.stylesheet))
    }

    var body: some HTML {
        main {
            h1 { "Local Games" }
            p { "Wait here, \(name), while other players join." }
            h2 { "Available Players" }
            PlayerList(players: players)
            noscript { a(.href("/")) { "↻ Refresh" } }
            form(.method(.post), .action(Scramble.path)) {
                button(.type(.submit)) { "Start Scramble" }
            }
            form(.method(.post), .action("/signout")) {
                button(.type(.submit)) { "Quit" }
            }
        }
        script("""
            const source = new EventSource("/lobby")
            source.addEventListener("message", (event) => {
                document.querySelector("#lobby").outerHTML = event.data
            })
            source.addEventListener("redirect", (event) => {
                location.href = event.data
            })
            """)
    }

    struct PlayerList: HTML {
        let players: [String]

        var content: some HTML {
            ul(.id("lobby")) {
                for player in players {
                    li { player }
                }
            }
        }
    }
}
