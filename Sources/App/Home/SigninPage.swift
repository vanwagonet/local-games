import Elementary

struct SigninPage: HTMLDocument {
    var name: String?
    var returnTo: String?

    let title = "Local Games"
    let lang = "en"

    var head: some HTML {
        meta(.charset(.utf8))
        meta(.name(.viewport), .content("width=device-width, initial-scale=1.0"))
        link(.href("/icon.svg"), .rel(.icon))
        link(.href("/style.css"), .rel(.stylesheet))
    }

    var body: some HTML {
        main {
            h1 { "Local Games" }
            p { "Play together, with a server on your local network." }
            form(.method(.post), .action("/")) {
                if let returnTo { input(.type(.hidden), .name("returnTo"), .value(returnTo)) }
                fieldset {
                    legend { "Sign In" }
                    label {
                        "Player Name"
                        input(
                            .type(.text),
                            .name("name"),
                            .placeholder("Please enter your name"),
                            .pattern(".*\\S.*"),
                            .required,
                            .value(name ?? "")
                        )
                    }
                    button(.type(.submit)) {
                        "Play"
                    }
                }
            }
        }
    }
}
