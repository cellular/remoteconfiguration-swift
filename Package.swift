// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "RemoteConfiguration",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v5)
    ],
    products: [
        .library(name: "RemoteConfiguration", targets: ["RemoteConfiguration"])
    ],
    dependencies: [
        .package(url: "https://github.com/cellular/cellular-swift.git", from: "6.0.0"),
        .package(url: "https://github.com/cellular/localstorage-swift.git", from: "6.0.0")
    ],
    targets: [
        .target(name: "RemoteConfiguration", dependencies: ["CELLULAR", "LocalStorage"]),
        .testTarget(name: "RemoteConfigurationTests", dependencies: ["RemoteConfiguration"]),
    ]
)
