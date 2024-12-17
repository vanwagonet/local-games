struct Identifier<Type, RawValue: Hashable & Sendable>: Hashable, RawRepresentable, Sendable {
    let rawValue: RawValue
}

extension Identifier where RawValue: FixedWidthInteger {
    init?(base36: String) {
        guard let rawValue = RawValue(base36, radix: 36) else { return nil }
        self.init(rawValue: rawValue)
    }

    var base36: String { String(rawValue, radix: 36) }
}

extension Identifier where RawValue: FixedWidthInteger & UnsignedInteger {
    static var random: Self { Self(rawValue: RawValue.random(in: 1...RawValue.max)) }

    static func next(avoiding ids: any Collection<Self>) -> Self {
        var id: Self
        repeat { id = random } while ids.contains(id)
        return id
    }
}
