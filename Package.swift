// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SystemMonitor",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SystemMonitor", targets: ["SystemMonitor"])
    ],
    targets: [
        .executableTarget(
            name: "SystemMonitor",
            path: "Sources/SystemMonitor"
        )
    ]
)