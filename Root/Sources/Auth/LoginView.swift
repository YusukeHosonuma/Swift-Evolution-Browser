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
    @Environment(\.colorScheme) private var colorScheme

    @State private var inProgress: Bool = false
    @State private var isPresentedLoginFailedAlert: Bool = false

    public init() {}

    public var body: some View {
        #if os(macOS)
        VStack {
            Text("Login").font(.title2).bold()
            Text("Please select login method:").font(.body).padding(2)
            Spacer()
            appleLoginButton()
            googleLoginButton()
        }
        .padding(24.0)
        .frame(width: 360, height: 180)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        #else
        NavigationView {
            VStack(alignment: .center) {
                appleLoginButton().padding()
                googleLoginButton()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        #endif
    }

    private func appleLoginButton() -> some View {
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

    private func googleLoginButton() -> some View {
        // FIXME: macOS は GoogleSignIn-iOS v6.2.0 のリリース待ち
        // https://github.com/google/GoogleSignIn-iOS
        #if os(macOS)
        EmptyView()
        #else
        GoogleLoginButton { error in
            if let _ = error {
                isPresentedLoginFailedAlert = true
            } else {
                dismiss()
            }
        }
        .frame(width: 280, height: 44)
        #endif
    }
}
