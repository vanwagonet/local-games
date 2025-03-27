import HTML

struct LobbyPage: Markup {
    var name: String
    var players: [String]

    var markup: some Markup {
        HTML(.lang("en")) {
            Head { head }
            Body { body }
        }
    }

    @MarkupBuilder var head: some MetadataContent {
        Meta(.charset(.utf8))
        Title { "Local Games" }
        Meta(.name("viewport"), .content("width=device-width, initial-scale=1.0"))
        Link(.href("/icon.svg"), .rel(.icon))
        NoScript { Meta(.httpEquiv("refresh"), .content("5")) }
        Link(.href("/style.css"), .rel(.stylesheet))
    }

    @MarkupBuilder var body: some HTMLContent {
        Main {
            H1 { "Local Games" }
            P { "Wait here, \(name), while other players join." }
            H2 { "Available Players" }
            PlayerList(players: players)
            NoScript { A(.href("/")) { "↻ Refresh" } }
            Form(.method(.post), .action(Scramble.path)) {
                Button(.type(.submit), .name("size"), .value("4")) { "4x4 Scramble" }
                Button(.type(.submit), .name("size"), .value("5")) { "5x5 Scramble" }
            }
            Form(.method(.post), .action("/signout")) {
                Button(.type(.submit)) { "Quit" }
            }
        }
        Script("""
            const source = new EventSource("\(Lobby.path)")
            source.addEventListener("message", (event) => {
                document.querySelector("#lobby").outerHTML = event.data
            })
            source.addEventListener("redirect", (event) => {
                location.href = event.data
            })
            """)
    }

    struct PlayerList: HTMLContent {
        let players: [String]

        var markup: some HTMLContent {
            UL(.id("lobby")) {
                for player in players {
                    LI { player }
                }
            }
        }
    }
}
