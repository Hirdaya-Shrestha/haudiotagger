// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "haudiotagger",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "haudiotagger", targets: ["haudiotagger"])
    ],
    targets: [
        .binaryTarget(
            name: "haudiotaggerFFI",
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v2.0.5/ios.zip",
            checksum: "232f9cf584d187f3015dcac154670be218c0093b763a9c68f7978779999562c9"
        ),
        .target(
            name: "haudiotagger",
            dependencies: ["haudiotaggerFFI"],
            path: "Sources/haudiotagger"
        )
    ]
)
