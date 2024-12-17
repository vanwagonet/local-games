import Elementary

struct CountDown: HTML {
    let remaining: Duration

    var content: some HTML {
        style("""
            \(keyframes("m1", period: 600, scale: 60))
            \(keyframes("s10", period: 60, scale: 10))
            \(keyframes("s1", period: 10, scale: 1))
            @keyframes hide { from, to { visibility:hidden } }
            
            .countdown-digit { position:relative; animation:1s forwards hide }
            .countdown-digit > span { display:inline-block; position:absolute;
                transform-origin-z:1lh; transform:rotateX(45deg); opacity:0 }
            .countdown-digit + span { animation:0s linear hide }
            """)
        pre(.style("font-family:ui-monospace")) {
            digit("m1", to: 9, period: 600, scale: 60)
            ":"
            digit("s10", to: 5, period: 60, scale: 10)
            digit("s1", to: 9, period: 10, scale: 1)
        }
    }

    func keyframes(_ name: String, period: Double, scale: Double) -> String {
        let time = 0.2 // How long is the animation in.
        let start = time / period * 100
        let end = scale / period * 100
        return """
        @keyframes \(name) {
            0% { transform:rotateX(-45deg); opacity:0 }
            \(start)%, \(end)% { transform:none; opacity:1 }
            \(start + end)%, 100% { transform:rotateX(45deg); opacity:0 }
        }
        """
    }

    @HTMLBuilder func digit(_ name: String, to: Int, period: Double, scale: Double) -> some HTML {
        let seconds = remaining.seconds
        let end = seconds - scale + 1
        span(.class("countdown-digit"), .style("animation-delay:\(end)s")) {
            for digit in 0...to {
                let count = (seconds / period + 2).rounded(.down)
                let delay = end.truncatingRemainder(dividingBy: period) - period - Double(digit) * scale - 0.2
                span(.style("animation:\(period)s \(count) \(delay)s \(name)")) {
                    String(digit)
                }
            }
        }
        span(.style("animation-duration:\(end)s")) { "0" }
    }
}
