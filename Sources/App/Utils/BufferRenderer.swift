import Hummingbird
import Markup

final class BufferRenderer: MarkupRenderer {
    var buffer = ByteBuffer()
    var context: MarkupContext

    init(lang: String = "en") {
        self.context = MarkupContext(lang: lang)
    }

    @inlinable func render(_ markup: String) {
        buffer.writeString(markup)
    }

    @inlinable func renderSubstring(_ markup: Substring) {
        buffer.writeSubstring(markup)
    }

    @inlinable func renderStaticString(_ markup: StaticString) {
        buffer.writeStaticString(markup)
    }

    @inlinable func renderUTF8CodeUnit(_ markup: UTF8.CodeUnit) {
        buffer.writeRepeatingByte(markup, count: 1)
    }

    @inlinable func renderUTF8CodeUnits<C>(_ markup: C) where C: Collection, C.Element == UInt8 {
        buffer.writeBytes(markup)
    }
}

extension Markup {
    func render(lang: String = "en") -> ByteBuffer {
        let renderer = BufferRenderer(lang: lang)
        renderer.render(self)
        return renderer.buffer
    }

    func render(lang: String = "en") -> String {
        String(buffer: render(lang: lang))
    }
}

extension ResponseBody {
    static func markup<M: Markup>(lang: String = "en", @MarkupBuilder markup: () -> M) -> ResponseBody {
        ResponseBody(byteBuffer: markup().render(lang: lang))
    }
}
