// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "WorkdayBar",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "WorkdayBar",
            exclude: [
                "Resources/Info.plist"
            ],
            resources: [
                .copy("Resources/default-logo.png")
            ]
        ),
        .testTarget(
            name: "WorkdayBarTests",
            dependencies: ["WorkdayBar"]
        )
    ]
)
