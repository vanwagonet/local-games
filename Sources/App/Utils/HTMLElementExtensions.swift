import Elementary

protocol HTMLRawContent {}
extension HTMLTag.script: HTMLRawContent {}
extension HTMLTag.style: HTMLRawContent {}

extension HTMLElement where Tag: HTMLRawContent, Content == HTMLRaw {
    init(_ text: String) {
        self.init { HTMLRaw(text) }
    }
}

// meta tag attributes
public extension HTMLAttribute where Tag == HTMLTag.meta {
    static func httpEquiv(_ value: String) -> Self {
        HTMLAttribute(name: "http-equiv", value: value)
    }
}

// pattern attribute
public extension HTMLTrait.Attributes {
    protocol pattern {}
    protocol autocapitalize {}
}

extension HTMLTag.input: HTMLTrait.Attributes.pattern {}
extension HTMLTag.textarea: HTMLTrait.Attributes.pattern {}

public extension HTMLAttribute where Tag: HTMLTrait.Attributes.pattern {
    static func pattern(_ value: String) -> Self {
        HTMLAttribute(name: "pattern", value: value)
    }
}

extension HTMLTag.input: HTMLTrait.Attributes.autocapitalize {}
extension HTMLTag.textarea: HTMLTrait.Attributes.autocapitalize {}

public extension HTMLAttribute where Tag: HTMLTrait.Attributes.autocapitalize {
    static func autocapitalize(_ value: String) -> Self {
        HTMLAttribute(name: "autocapitalize", value: value)
    }
}

public extension HTMLTag {
    enum defs: HTMLTrait.Paired { public static let name = "defs" }
    enum linearGradient: HTMLTrait.Paired { public static let name = "linearGradient" }
    enum path: HTMLTrait.Paired { public static let name = "path" }
    enum stop: HTMLTrait.Paired { public static let name = "stop" }
    enum text: HTMLTrait.Paired { public static let name = "text" }
    enum use: HTMLTrait.Paired { public static let name = "use" }
}

public typealias defs<Content: HTML> = HTMLElement<HTMLTag.defs, Content>
public typealias linearGradient<Content: HTML> = HTMLElement<HTMLTag.linearGradient, Content>
public typealias path = HTMLElement<HTMLTag.path, EmptyHTML>
public typealias stop = HTMLElement<HTMLTag.stop, EmptyHTML>
public typealias text = HTMLElement<HTMLTag.text, HTMLText>
public typealias use = HTMLElement<HTMLTag.use, EmptyHTML>

extension HTMLTag.use: HTMLTrait.Attributes.href {}

public extension HTMLAttribute where Tag == HTMLTag.svg {
    static func viewBox(
        minX: any LosslessStringConvertible,
        minY: any LosslessStringConvertible,
        width: any LosslessStringConvertible,
        height: any LosslessStringConvertible
    ) -> Self {
        HTMLAttribute(name: "viewBox", value: "\(minX) \(minY) \(width) \(height)")
    }
}

public extension HTMLAttribute where Tag == HTMLTag.linearGradient {
    static func gradientTransform(_ value: String) -> Self {
        HTMLAttribute(name: "gradientTransform", value: value)
    }
}

public extension HTMLAttribute where Tag == HTMLTag.path {
    static func d(_ value: String) -> Self {
        HTMLAttribute(name: "d", value: value)
    }
}

public extension HTMLAttribute where Tag == HTMLTag.stop {
    static func offset(_ value: String) -> Self {
        HTMLAttribute(name: "offset", value: value)
    }
    static func stopColor(_ value: String) -> Self {
        HTMLAttribute(name: "stop-color", value: value)
    }
}

// x, y attribute
public extension HTMLTrait.Attributes {
    protocol coordinates {}
}

extension HTMLTag.text: HTMLTrait.Attributes.coordinates {}
extension HTMLTag.use: HTMLTrait.Attributes.coordinates {}

public extension HTMLAttribute where Tag: HTMLTrait.Attributes.coordinates {
    static func x(_ value: any LosslessStringConvertible) -> Self {
        HTMLAttribute(name: "x", value: String(value))
    }
    static func y(_ value: any LosslessStringConvertible) -> Self {
        HTMLAttribute(name: "y", value: String(value))
    }
}


public extension HTMLElement {
    /// Creates a new HTML element with the specified attributes and content.
    /// - Parameters:
    ///  - attributes: The attributes to apply to the element.
    @inlinable
    init(_ attributes: HTMLAttribute<Tag>...) where Content == EmptyHTML {
        self.init(attributes: attributes) { EmptyHTML() }
    }

    /// Creates a new HTML element with the specified attributes and content.
    /// - Parameters:
    ///  - attributes: The attributes to apply to the element as an array.
    @inlinable
    init(attributes: [HTMLAttribute<Tag>]) where Content == EmptyHTML {
        self.init(attributes: attributes) { EmptyHTML() }
    }
}
