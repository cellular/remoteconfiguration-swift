// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "RemoteConfiguration",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12),
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
        .target(name: "RemoteConfiguration", dependencies: [.product(name: "CELLULAR", package: "cellular-swift"), .product(name: "LocalStorage", package: "localstorage-swift")]),
        .testTarget(name: "RemoteConfigurationTests", dependencies: ["RemoteConfiguration"]),
    ]
)
