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
        
        // ✅ Reference to Model. (ViewModel is redundant in this case)
        @EnvironmentObject var authState: AuthState

        @State var isPresentConfirmSheet = false
        @State var isPresentAuthView = false

        func body(content: Content) -> some View {
            content
                .toolbar {
                    ToolbarItem {
                        Button(action: onTapAccountButton) {
                            Image(systemSymbol: .personFill)
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
        
        // ✅ Define events in self.
        
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

//final class AppToolbarViewModel: ObservableObject {
//    @Published var isPresentConfirmSheet = false
//    @Published var isPresentFirebaseAuthView = false
//    @Published var isLogin = false
//
//    private var authState: AuthState!
//
//    // MARK: Initialize
//
//    func onAppear(authState: AuthState) {
//        self.authState = authState
//        authState.isLogin.assign(to: &$isLogin)
//    }
//
//    // MARK: Action
//
//    func onTapAccountButton() {
//        if authState.isLogin.value {
//            isPresentConfirmSheet = true
//        } else {
//            isPresentFirebaseAuthView = true
//        }
//    }
//
//    func onTapLogout() {
//        authState.logout()
//    }
//}
//
