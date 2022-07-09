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
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "9.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "6.1.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftParamTest.git", from: "2.2.0"),
        .package(url: "https://github.com/YusukeHosonuma/SFReadableSymbols.git", from: "1.0.0"),
        .package(url: "https://github.com/sindresorhus/Defaults.git", from: "6.2.1"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftUI-Common.git", from: "1.0.0"),
        .package(url: "https://github.com/YusukeHosonuma/SwiftUI-Simulator.git", branch: "main"),
        .package(url: "https://github.com/YusukeHosonuma/ObservableObjectDebugger.git", branch: "main"),
    ],
    targets: [
        //
        // 💻 Root
        //
        .target(name: "Root", dependencies: [
            "Auth",
            "Proposal",
            "Setting",
            "ObservableObjectDebugger",
        ]),
        .testTarget(name: "RootTests", dependencies: ["Root"]),
        //
        // 🚀 Feature
        //
        .target(name: "Proposal", dependencies: [
            "Core",
            "Auth",
            "Service",
            "SwiftEvolutionAPI",
            "ObservableObjectDebugger",
            .product(name: "Algorithms", package: "swift-algorithms"),
        ]),
        .target(name: "Setting", dependencies: [
            "Core",
            "Auth",
            "Service",
            "ObservableObjectDebugger",
        ]),
        //
        // ☁️ Service
        //
        .target(name: "Service", dependencies: [
            "Core",
            "Auth",
            "ObservableObjectDebugger",
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreCombine-Community", package: "firebase-ios-sdk"),
        ]),
        .target(name: "Auth", dependencies: [
            "Core",
            "ObservableObjectDebugger",
            .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS", condition: .when(platforms: [.iOS])),
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestoreCombine-Community", package: "firebase-ios-sdk"),
        ]),
        //
        // ⚙️ Core
        //
        .target(name: "Core", dependencies: [
            "ObservableObjectDebugger",
            "SFReadableSymbols",
            "Defaults",
            .product(name: "SwiftUICommon", package: "SwiftUI-Common"),
            .product(name: "SwiftUISimulator", package: "SwiftUI-Simulator", condition: .when(platforms: [.iOS])),
            .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk", condition: .when(platforms: [.iOS])),
        ]),
        //
        // 📚 Library
        //
        .target(name: "SwiftEvolutionAPI", dependencies: []),
        //
        // ☑️ Tests
        //
        .testTarget(name: "AuthTests", dependencies: ["Auth"]),
        .testTarget(name: "ProposalTests", dependencies: ["Proposal", "SwiftParamTest"]),
    ]
)
