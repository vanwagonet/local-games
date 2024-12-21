// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LocalGames",
    platforms: [ .macOS(.v14) ],
    products: [
        .executable(name: "App", targets: [ "App" ]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.2"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/vanwagonet/markup", branch: "main"),
    ],
    targets: [
        .executableTarget(name: "App",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HTML", package: "markup"),
                .product(name: "Markup", package: "markup"),
                .product(name: "SVG", package: "markup"),
            ],
            path: "Sources/App"
        ),
        .testTarget(name: "AppTests",
            dependencies: [
                .byName(name: "App"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ],
            path: "Tests/AppTests"
        )
    ]
)
