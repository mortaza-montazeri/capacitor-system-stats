// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetacoltdCapacitorSystemStats",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "NetacoltdCapacitorSystemStats",
            targets: ["SystemStatsPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "SystemStatsPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/SystemStatsPlugin"),
        .testTarget(
            name: "SystemStatsPluginTests",
            dependencies: ["SystemStatsPlugin"],
            path: "ios/Tests/SystemStatsPluginTests")
    ]
)