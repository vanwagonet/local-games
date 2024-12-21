import HTML

struct SigninPage: Markup {
    var name: String?
    var returnTo: String?

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
        Link(href: "/icon.svg", .rel(.icon))
        Link(href: "/style.css", .rel(.stylesheet))
    }

    @MarkupBuilder var body: some HTMLContent {
        Main {
            H1 { "Local Games" }
            P { "Play together, with a server on your local network." }
            Form(.method(.post), .action("/")) {
                if let returnTo {
                    Input(
                        .init("type", value: Text(verbatim: "hidden")),
                        .init("name", value: Text(verbatim: "returnTo")),
                        .init("value", value: Text(verbatim: returnTo))
                    )
                }
                FieldSet {
                    Legend { "Sign In" }
                    Label {
                        "Player Name"
                        Input(
                            .init("type", value: Text(verbatim: "text")),
                            .init("name", value: Text(verbatim: "name")),
                            .init("placeholder", value: Text("Please enter your name")),
                            .init("pattern", value: Text(verbatim: ".*\\S.*")),
                            .init("required"),
                            .init("value", value: Text(verbatim: name ?? ""))
                        )
                    }
                    Button(.type(.submit)) {
                        "Play"
                    }
                }
            }
        }
    }
}
