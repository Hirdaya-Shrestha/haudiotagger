// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "haudiotagger",
    platforms: [.macOS(.v10_14)],
    products: [
        .library(name: "haudiotagger", targets: ["haudiotagger"])
    ],
    targets: [
        .binaryTarget(
            name: "haudiotaggerFFI",
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v3.0.0/macos.zip",
            checksum: "d26386276df9e8e1864edbafe061e9359e6019862e6d643dc39a9f5dc132ad7c"
        ),
        .target(
            name: "haudiotagger",
            dependencies: ["haudiotaggerFFI"],
            path: "Sources/haudiotagger"
        )
    ]
)
