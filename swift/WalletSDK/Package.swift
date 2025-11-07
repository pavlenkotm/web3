// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WalletSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "WalletSDK",
            targets: ["WalletSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),
        .package(url: "https://github.com/Boilertalk/Web3.swift.git", from: "0.8.4"),
    ],
    targets: [
        .target(
            name: "WalletSDK",
            dependencies: [
                "BigInt",
                "CryptoSwift",
                .product(name: "Web3", package: "Web3.swift"),
            ]),
        .testTarget(
            name: "WalletSDKTests",
            dependencies: ["WalletSDK"]),
    ]
)
