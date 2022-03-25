//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/10.
//

import Auth
import Core
import Foundation
import SwiftUI

struct AppToolbar: ViewModifier {
    @EnvironmentObject private var authState: AuthState

    @State private var isPresentConfirmSheet = false
    @State private var isPresentAuthView = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                // ☑️ Moved to `Setting` tab.
                // ToolbarItem {
                //     Button(action: onTapAccountButton) {
                //         Image(systemName: "person.fill")
                //     }
                //     .confirmationDialog("Are you logout?", isPresented: $isPresentConfirmSheet) {
                //         if authState.isLogin {
                //             Button("Logout", action: onTapLogout)
                //         }
                //     }
                // }

                //
                // Toggle sidebar
                //
                #if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button {
                        toggleSidebar()
                    } label: {
                        Image(systemName: "sidebar.leading")
                    }
                }
                #endif
            }
            .sheet(isPresented: $isPresentAuthView) {
                LoginView()
            }
    }

    // MARK: Events

    // private func onTapLogout() {
    //     authState.logout()
    // }

    // private func onTapAccountButton() {
    //     if authState.isLogin {
    //         isPresentConfirmSheet = true
    //     } else {
    //         isPresentAuthView = true
    //     }
    // }
}

extension View {
    func appToolbar() -> some View {
        modifier(AppToolbar())
    }
}
