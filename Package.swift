// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Antasupport",
    platforms: [.macOS(.v14)],
    dependencies: [
        // Embedded terminal emulator. Spawns a real local shell via a pty.
        // Pulled in automatically by Xcode / SwiftPM — nothing to install by hand.
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.2.0")
    ],
    targets: [
        .executableTarget(
            name: "Antasupport",
            dependencies: [
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ]
        )
    ]
)
