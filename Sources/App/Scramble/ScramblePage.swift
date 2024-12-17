import Elementary

struct ScramblePage: HTMLDocument {
    let players: [Session.ID: Session]
    let state: Scramble.State

    init(players: [Session], state: Scramble.State) {
        self.players = Dictionary(uniqueKeysWithValues: players.map { ($0.id, $0) })
        self.state = state
    }

    let title = "Scramble - Local Games"
    let lang = "en"

    var head: some HTML {
        meta(.charset(.utf8))
        meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
        link(.href("/icon.svg"), .rel(.icon))
        if state.remaining > .zero {
            meta(.httpEquiv("refresh"), .content(String(state.remaining.seconds + 1)))
        }
        link(.href("\(Scramble.path).css"), .rel(.stylesheet))
        style(".fill::after { animation-delay:\((state.remaining - .minutes(3) - .seconds(3)).seconds)s }")
    }

    var body: some HTML {
        main {
            h1 { "Scramble" }
            if state.remaining > .zero {
                CountDown(remaining: state.remaining)
            } else {
                h2 { "Your total: \(state.entries.map(\.score).reduce(0, +))p" }
                p { a(.href("/lobby")) { "Return to lobby" } }
            }
            section(.class("fill")) {
                svg(
                    .class("board"),
                    .viewBox(minX: -0.5, minY: -0.5, width: state.board.count, height: state.board.count)
                ) {
                    defs {
                        linearGradient(.id("die-g"), .gradientTransform("rotate(90)")) {
                            stop(.offset("0%"), .stopColor("rgba(255,255,255,0.2)"))
                            stop(.offset("50%"), .stopColor("transparent"))
                            stop(.offset("100%"), .stopColor("rgba(0,0,0,0.2)"))
                        }
                        let diebg = "M-.38-.48h.76q.1 0 .1.1v.76q0 .1-.1.1h-.76q-.1 0-.1-.1v-.76q0-.1.1-.1z"
                        path(.id("die-bg"), .d(diebg))
                        path(.id("die-f"), .d("\(diebg)m.38 .04a.44.44 0 0 0 0 .88a.44.44 0 0 0 0-.88"))
                    }
                    for y in state.board.indices {
                        for x in state.board[y].indices {
                            use(.href("#die-bg"), .x(x), .y(y))
                            use(.href("#die-f"), .x(x), .y(y))
                        }
                    }
                    if state.remaining == .zero {
                        ForEach(state.entries) { entry in
                            for (i, line) in entry.paths.enumerated() {
                                path(
                                    .id("\(entry.word)-\(i+1)"), .class("entry-path"),
                                    .d("M\(line.map { "\($0.x) \($0.y)" } .joined(separator: " "))")
                                )
                            }
                        }
                    }
                    for y in state.board.indices {
                        for x in state.board[y].indices {
                            text(.x(x), .y(y)) { HTMLText(String(state.board[y][x])) }
                        }
                    }
                }
                if state.remaining > .zero {
                    form(.method(.post), .action("\(Scramble.path(state.gameID))/entries")) {
                        input(.autofocus, .autocapitalize("none"), .name("word"), .placeholder("word"))
                        button(.type(.submit)) { "add" }
                    }
                }
            }
            ul(.id("words")) {
                ForEach(state.entries) { entry in
                    li {
                        if state.remaining > .zero {
                            HTMLText(entry.word)
                        } else {
                            ScrambleEntryListItem(entry: entry, players: players)
                        }
                    }
                }
            }
            .attributes(.class("simple"), when: state.remaining > .zero)
        }
        script("""
        const input = document.querySelector("[name=word]")
        input.focus()
        const parser = new DOMParser()
        document.querySelector("form")?.addEventListener("submit", async (event) => {
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

struct ScrambleEntryListItem: HTML {
    let entry: Scramble.Entry
    let players: [Session.ID: Session]

    var content: some HTML {
        if entry.isValid {
            "\(entry.word) \(entry.value)p"
        } else {
            s { "\(entry.word) \(entry.value)p" }
        }
        if entry.paths.isEmpty {
            " Not found."
        }
        for i in entry.paths.indices {
            HTMLRaw(" ")
            a(.href("#\(entry.word)-\(i+1)")) { "\(i+1)" }
        }
        if !entry.inDict {
            " Not in dictionary."
        }
        if !entry.alsoFoundBy.isEmpty {
            " Also found by: \(entry.alsoFoundBy.compactMap { players[$0]?.name } .formatted(.list(type: .and)))"
        }
    }
}
