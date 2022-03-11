// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Root",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "Root", targets: ["Root"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "8.10.0")),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/uber/needle.git", .upToNextMajor(from: "0.17.0")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "2.1.3")),
        .package(url: "https://github.com/apple/swift-algorithms", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "Root", dependencies: [
            "Auth",
            "Proposal",
            .product(name: "NeedleFoundation", package: "needle")
        ]),
        .target(name: "Core", dependencies: [
            "SFSafeSymbols",
        ]),
        .target(name: "Auth", dependencies: [
            "Core",
            .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS", condition: .when(platforms: [.iOS])),
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        ]),
        .target(name: "Proposal", dependencies: [
            "Core",
            "Auth",
            "SwiftEvolutionAPI",
            .product(name: "Algorithms", package: "swift-algorithms"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreCombine-Community", package: "firebase-ios-sdk"),
        ]),
        .target(name: "SwiftEvolutionAPI", dependencies: []),
        .testTarget(
            name: "RootTests",
            dependencies: ["Root"]),
    ]
)
