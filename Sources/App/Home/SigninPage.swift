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
                    Input(.type(.hidden), .name("returnTo"), .value(returnTo))
                }
                FieldSet {
                    Legend { "Sign In" }
                    Label {
                        "Player Name"
                        Input(
                            .type(.text),
                            .name("name"),
                            .placeholder(Text("Please enter your name")),
                            .pattern(".*\\S.*"),
                            .required,
                            .value(name ?? "")
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
