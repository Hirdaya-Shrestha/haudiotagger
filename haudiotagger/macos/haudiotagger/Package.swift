// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "haudiotagger",
    platforms: [.macOS(.v10_14)],
    libraries: [
        .binaryTarget(
            name: "haudiotagger",
            path: "Frameworks/haudiotagger.xcframework"
        )
    ]
)
