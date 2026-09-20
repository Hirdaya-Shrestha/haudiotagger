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
            name: "haudiotagger",
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v2.0.4/ios.zip",
            checksum: "397025e6507c3c3b3d596bf7f6a9d961d073f2fca5c1a5900edc21759012613a"
        )
    ]
)
