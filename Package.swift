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
        .library(name: "RemoteConfiguration", type: .dynamic, targets: ["RemoteConfiguration"])
    ],
    dependencies: [
        .package(url: "https://github.com/cellular/cellular-swift.git", .branch("feature/xcode_11.4")),
        .package(url: "https://github.com/cellular/networking-swift.git", .branch("feature/xcode_11.4")),
        .package(url: "https://github.com/cellular/localstorage-swift.git", .branch("feature/xcode_11.4"))
    ],
    targets: [
        .target(name: "RemoteConfiguration", dependencies: ["CELLULAR", "Networking", "LocalStorage"]),
        .testTarget(name: "RemoteConfigurationTests", dependencies: ["RemoteConfiguration"]),
    ]
)
