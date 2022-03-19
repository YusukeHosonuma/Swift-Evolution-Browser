//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/10.
//

import Foundation
import SwiftUI
import Auth
import Core

struct AppToolbar: ViewModifier {
    
    @EnvironmentObject private var authState: AuthState
    
    @State private var isPresentConfirmSheet = false
    @State private var isPresentAuthView = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button(action: onTapAccountButton) {
                        Image(systemName: "person.fill")
                    }
                    .confirmationDialog("Are you logout?", isPresented: $isPresentConfirmSheet) {
                        if authState.isLogin {
                            Button("Logout", action: onTapLogout)
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentAuthView) {
                LoginView()
            }
    }
    
    // MARK: Events
    
    private func onTapLogout() {
        authState.logout()
    }
    
    private func onTapAccountButton() {
        if authState.isLogin {
            isPresentConfirmSheet = true
        } else {
            isPresentAuthView = true
        }
    }
}

extension View {
    func appToolbar() -> some View {
        self.modifier(AppToolbar())
    }
}
