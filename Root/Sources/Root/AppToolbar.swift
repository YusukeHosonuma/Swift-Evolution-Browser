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
    @StateObject var viewModel: AppToolbarViewModel = .init()
    @Environment(\.authState) var authState: AuthState!
    
    init() {}
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button(action: viewModel.onTapAccountButton) {
                        Image(systemSymbol: .personFill)
                    }
                    .confirmationDialog("Are you logout?", isPresented: $viewModel.isPresentConfirmSheet) {
                        if viewModel.isLogin {
                            Button("Logout", action: viewModel.onTapLogout)
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentFirebaseAuthView) {
                LoginView()
            }
            .task {
                viewModel.onAppear(authState: authState)
            }
    }
}

final class AppToolbarViewModel: ObservableObject {
    @Published var isPresentConfirmSheet = false
    @Published var isPresentFirebaseAuthView = false
    @Published var isLogin = false
    
    private var authState: AuthState!
    
    // MARK: Initialize
    
    func onAppear(authState: AuthState) {
        self.authState = authState
        authState.isLogin.assign(to: &$isLogin)
    }
    
    // MARK: Action
    
    func onTapAccountButton() {
        if authState.isLogin.value {
            isPresentConfirmSheet = true
        } else {
            isPresentFirebaseAuthView = true
        }
    }

    func onTapLogout() {
        authState.logout()
    }
}

extension View {
    func appToolbar() -> some View {
        self.modifier(AppToolbar())
    }
}
 
