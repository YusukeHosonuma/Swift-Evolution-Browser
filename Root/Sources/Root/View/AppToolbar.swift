//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/10.
//

import Auth
import Core
import Foundation
import SFReadableSymbols
import SwiftUI
import ObservableObjectDebugger

struct AppToolbar: ViewModifier {
    @EnvironmentObject private var authState: AuthState

    @State private var isPresentConfirmSheet = false
    @State private var isPresentAuthView = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                //
                // Toggle sidebar
                //
                #if os(macOS)
                ToolbarItem(placement: .navigation) {
                    Button {
                        toggleSidebar()
                    } label: {
                        Image(symbol: "􀰱")
                    }
                }
                #endif
            }
            .debugObserve(authState)
    }
}

extension View {
    func appToolbar() -> some View {
        modifier(AppToolbar())
    }
}
