// swift-tools-version: 5.9
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "skipnotes",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "App", type: .dynamic, targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
