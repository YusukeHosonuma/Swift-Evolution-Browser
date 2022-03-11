//
//  SwiftEvolutionBroswerAppApp.swift
//  Shared
//
//  Created by 細沼祐介 on 2022/03/09.
//

import SwiftUI
import NeedleFoundation
import Root
import Firebase

@main
struct MainApp: App {
    private let _component: RootComponent

    init() {
        // Initialize Firestore
        FirebaseApp.configure()
        
        // Initialize needle
        registerProviderFactories()
        
        // Initialize component
        _component = RootComponent()
    }
    
    var body: some Scene {
        WindowGroup {
            _component.makeView()
        }
    }
}
