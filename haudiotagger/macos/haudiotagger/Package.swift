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
            name: "haudiotagger",
            url: "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v2.0.4/macos.zip",
            checksum: "f80bbcf26cdf1f4a38da5ba21b5b36e5e9d1d8d0129d3bef362b75bfb2bd77e5"
        )
    ]
)
