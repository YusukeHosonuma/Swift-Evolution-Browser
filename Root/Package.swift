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
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "8.10.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "6.1.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.0"),
        .package(url: "https://github.com/YusukeHosonuma/SFReadableSymbols.git", from: "1.0.0"),
    ],
    targets: [
        //
        // 💻 Root
        //
        .target(name: "Root", dependencies: [
            "Auth",
            "Proposal",
            "SFReadableSymbols",
        ]),
        .testTarget(name: "RootTests", dependencies: ["Root"]),
        //
        // 🚀 Feature
        //
        .target(name: "Proposal", dependencies: [
            "Core",
            "Auth",
            "SwiftEvolutionAPI",
            .product(name: "Algorithms", package: "swift-algorithms"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreCombine-Community", package: "firebase-ios-sdk"),
        ]),
        .testTarget(name: "ProposalTests", dependencies: ["Proposal", "SwiftParamTest"]),
        //
        // ⚙️ Core
        //
        .target(name: "Core", dependencies: []),
        //
        // 📚 Library
        //
        .target(name: "SwiftEvolutionAPI", dependencies: []),
        .target(name: "Auth", dependencies: [
            .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS", condition: .when(platforms: [.iOS])),
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift-Beta", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreCombine-Community", package: "firebase-ios-sdk"),
        ]),
        .testTarget(name: "AuthTests", dependencies: ["Auth"]),
    ]
)
