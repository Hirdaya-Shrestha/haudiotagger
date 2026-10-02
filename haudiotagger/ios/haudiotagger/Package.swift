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
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v3.1.0/ios.zip",
            checksum: "111310d05acec9600798e7d75a711713e2dfa7dc21983fa923e85b14e816bcb0"
        ),
        .target(
            name: "haudiotagger",
            dependencies: ["haudiotaggerFFI"],
            path: "Sources/haudiotagger"
        )
    ]
)
