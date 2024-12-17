import Foundation

extension Duration {
    static func minutes<T: BinaryInteger>(_ minutes: T) -> Self {
        seconds(minutes * 60)
    }

    var seconds: TimeInterval {
        TimeInterval(components.seconds) + TimeInterval(components.attoseconds) * 1e-18
    }
}
