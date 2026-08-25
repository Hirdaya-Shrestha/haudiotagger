// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "haudiotagger",
    platforms: [.iOS(.v12)],
    libraries: [
        .binaryTarget(
            name: "haudiotagger",
            path: "Frameworks/haudiotagger.xcframework"
        )
    ]
)
