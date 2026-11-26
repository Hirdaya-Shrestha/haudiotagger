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
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v3.2.0/macos.zip",
            checksum: "ee419e6eec5cc7fcd6974942387a084012d317db8bb9845bcc8ec517f72744a6"
        ),
        .target(
            name: "haudiotagger",
            dependencies: ["haudiotaggerFFI"],
            path: "Sources/haudiotagger"
        )
    ]
)
