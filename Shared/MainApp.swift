//
//  SwiftEvolutionBroswerAppApp.swift
//  Shared
//
//  Created by 細沼祐介 on 2022/03/09.
//

import SwiftUI
import Root
import Firebase

@main
struct MainApp: App {
    init() {
        // Initialize Firestore
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
