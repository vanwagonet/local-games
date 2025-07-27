import HTML
import SVG

struct ScramblePage: Markup {
    let players: [Session.ID: Session]
    let state: Scramble.State

    init(players: [Session], state: Scramble.State) {
        self.players = Dictionary(uniqueKeysWithValues: players.map { ($0.id, $0) })
        self.state = state
    }

    var markup: some Markup {
        HTML(.lang("en")) {
            Head { head }
            Body { body }
        }
    }

    @MarkupBuilder var head: some MetadataContent {
        Meta(.charset(.utf8))
        Meta(.name("viewport"), .content("width=device-width, initial-scale=1.0"))
        Title { "Scramble - Local Games" }
        Link(.href("/icon.svg"), .rel(.icon))
        if state.remaining > .zero {
            Meta(.httpEquiv("refresh"), .content(String(state.remaining.seconds + 1)))
        }
        Link(.href("\(Scramble.path).css"), .rel(.stylesheet))
        let delay = (state.remaining - state.duration - .seconds(3)).seconds
        Style(".fill::after { animation-delay:\(delay)s }")
    }

    @MarkupBuilder var body: some HTMLContent {
        Main {
            H1 { "Scramble" }
            if state.remaining > .zero {
                CountDown(remaining: state.remaining)
            } else {
                H2 { "Your total: \(state.entries.map(\.score).reduce(0, +))p" }
                P { A(.href(Lobby.path)) { "Return to lobby" } }
            }
            Section(.class("fill")) {
                SVG(
                    .class("board"),
                    .viewBox(minX: -0.5, minY: -0.5, width: state.board.count, height: state.board.count)
                ) {
                    Defs {
                        LinearGradient(.id("die-g"), .gradientTransform(.rotate("90"))) {
                            Stop(.offset("0%"), .stopColor("rgba(255,255,255,0.2)"))
                            Stop(.offset("50%"), .stopColor("transparent"))
                            Stop(.offset("100%"), .stopColor("rgba(0,0,0,0.2)"))
                        }
                        let diebg = "M-.38-.48h.76q.1 0 .1.1v.76q0 .1-.1.1h-.76q-.1 0-.1-.1v-.76q0-.1.1-.1z"
                        Path(.id("die-bg"), .d(diebg))
                        Path(.id("die-f"), .d("\(diebg)m.38 .04a.44.44 0 0 0 0 .88a.44.44 0 0 0 0-.88"))
                    }
                    for y in state.board.indices {
                        for x in state.board[y].indices {
                            Use(.href("#die-bg"), .x(x), .y(y))
                            Use(.href("#die-f"), .x(x), .y(y))
                        }
                    }
                    if state.remaining == .zero {
                        for entry in state.entries {
                            for (i, line) in entry.paths.enumerated() {
                                Path(
                                    .id("\(entry.word)-\(i+1)"), .class("entry-path"),
                                    .d("M\(line.map { "\($0.x) \($0.y)" } .joined(separator: " "))")
                                )
                            }
                        }
                    }
                    for y in state.board.indices {
                        for x in state.board[y].indices {
                            TextElement(.x(x), .y(y)) { state.board[y][x] }
                        }
                    }
                }
                if state.remaining > .zero {
                    Form(.id("add-entry"), .method(.post), .action("\(Scramble.path(state.gameID))/entries")) {
                        Input(
                            .autoFocus,
                            .autoCapitalize(.none),
                            .autoComplete(.off),
                            .autoCorrect(.off),
                            .name("word"),
                            .placeholder(Text("word"))
                        )
                        Button(.type(.submit)) { "add" }
                    }
                }
            }
            UL(.id("words"), .if(state.remaining > .zero, .class("simple"))) {
                for entry in state.entries {
                    LI {
                        if state.remaining > .zero {
                            entry.word
                        } else {
                            ScrambleEntryListItem(entry: entry, players: players)
                        }
                    }
                }
            }
            if state.remaining > .zero {
                Form(.method(.post), .action("\(Scramble.path(state.gameID))/quit")) {
                    Button(.type(.submit)) { "Quit" }
                }
            }
        }
        Script("""
            const input = document.querySelector("[name=word]")
            input.focus()
            const parser = new DOMParser()
            document.getelementById("add-entry")?.addEventListener("submit", async (event) => {
                event.preventDefault()
                const form = event.target, data = new FormData(form)
                input.value = ""
                input.focus()
                try {
                    let response = await fetch(form.action, { method: form.method, body: new URLSearchParams(data) })
                    let html = await response.text()
                    let doc = parser.parseFromString(html, response.headers.get("content-type").split(";")[0])
                    document.querySelector("#words").replaceWith(doc.querySelector("#words"))
                } catch (error) {
                }
            })
            """)
    }
}

struct ScrambleEntryListItem: HTMLContent {
    let entry: Scramble.Entry
    let players: [Session.ID: Session]

    var markup: some HTMLContent {
        if entry.isValid {
            "\(entry.word) \(entry.value)p"
        } else {
            S { "\(entry.word) \(entry.value)p" }
        }
        if entry.paths.isEmpty {
            " Not found."
        }
        for i in entry.paths.indices {
            Text(verbatim: " ")
            A(.href("#\(entry.word)-\(i+1)")) { "\(i+1)" }
        }
        if !entry.inDict {
            " Not in dictionary."
        }
        if !entry.alsoFoundBy.isEmpty {
            " Also found by: \(entry.alsoFoundBy.compactMap { players[$0]?.name } .formatted(.list(type: .and)))"
        }
    }
}
