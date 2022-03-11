// swift-tools-version:5.5
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
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk", .upToNextMajor(from: "8.10.0")),
        .package(name: "GoogleSignIn", url: "https://github.com/google/GoogleSignIn-iOS.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/uber/needle.git", .upToNextMajor(from: "0.17.0")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "2.1.3")),
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
            .byName(name: "GoogleSignIn", condition: .when(platforms: [.iOS])),
            .product(name: "FirebaseAuth", package: "Firebase"),
        ]),
        .target(name: "Proposal", dependencies: [
            "Core",
            "SwiftEvolutionAPI",
            .product(name: "FirebaseFirestore", package: "Firebase"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "Firebase"),
            .product(name: "FirebaseFirestoreCombine-Community", package: "Firebase"),
        ]),
        .target(name: "SwiftEvolutionAPI", dependencies: []),
        .testTarget(
            name: "RootTests",
            dependencies: ["Root"]),
    ]
)
