// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StandUpTimer",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "StandUpTimer",
            path: "Sources",
            exclude: ["Resources/Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Resources/Info.plist"
                ])
            ]
        )
    ]
)
