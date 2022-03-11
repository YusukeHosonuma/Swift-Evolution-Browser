//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/10.
//

import Foundation
import SwiftUI

public struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State var inProgress: Bool = false
    @State var isPresentedLoginFailedAlert: Bool = false

    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                // FIXME: macOS は GoogleSignIn-iOS v6.2.0 のリリース待ち
                // https://github.com/google/GoogleSignIn-iOS
                #if os(iOS)
                GoogleLoginButton { error in
                    if let _ = error {
                        isPresentedLoginFailedAlert = true
                    } else {
                        dismiss()
                    }
                }
                .frame(width: 280, height: 44)
                .padding(.bottom)
                #endif
                AppleLoginButton(inProgress: $inProgress) { error in
                    if let _ = error {
                        isPresentedLoginFailedAlert = true
                    } else {
                        dismiss()
                    }
                }
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(width: 280, height: 44)
                .alert(isPresented: $isPresentedLoginFailedAlert) {
                    Alert(title: Text("Login is failed."))
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
