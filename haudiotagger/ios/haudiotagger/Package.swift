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
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v2.2.0/ios.zip",
            checksum: "d58f895205d6520d29d3c6bfed910c1d29901b4153f285daceb714f801fd731d"
        ),
        .target(
            name: "haudiotagger",
            dependencies: ["haudiotaggerFFI"],
            path: "Sources/haudiotagger"
        )
    ]
)
