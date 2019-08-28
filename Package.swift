// swift-tools-version:5.1
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
        .package(url: "https://github.com/cellular/networking-swift.git", from: "6.0.0"),
        .package(url: "https://github.com/cellular/localstorage-swift.git", from: "6.0.0")
    ],
    targets: [
        .target(name: "RemoteConfiguration", dependencies: ["CELLULAR", "Networking", "LocalStorage"]),
        .testTarget(name: "RemoteConfigurationTests", dependencies: ["RemoteConfiguration"]),
    ]
)
