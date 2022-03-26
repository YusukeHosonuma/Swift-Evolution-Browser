//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/25.
//

import Auth
import Foundation
import Service
import SFReadableSymbols
import SwiftUI

private let repositoryURLString = "https://github.com/YusukeHosonuma/Swift-Evolution-Browser"
private let repositoryURL = URL(string: repositoryURLString)!

private let twitterURL = URL(string: "https://twitter.com/tobi462")!

private var shareOnTwitterURL: URL = {
    let text = "Swift Evolution Browser (SE Browser) build with SwiftUI | Yusuke Hosonuma"
    let hashTags = ["SwiftUI", "iOSDev"].joined(separator: ",")
    let shareString = "https://twitter.com/intent/tweet?text=\(text)&url=\(repositoryURLString)&hashtags=\(hashTags)"
    let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    let url = URL(string: escapedShareString)!
    return url
}()

public struct SettingView: View {
    @EnvironmentObject private var viewModel: SettingViewModel

    public init() {}

    public var body: some View {
        List {
            //
            // 🙋‍♂️ Account section.
            //
            Section("Account") {
                if viewModel.isSignIn {
                    Button {
                        viewModel.onTapSignOut()
                    } label: {
                        Label("Sign-Out", symbol: "􀉭")
                    }
                } else {
                    Button {
                        viewModel.onTapSignIn()
                    } label: {
                        Label("Sign-In", symbol: "􀉭")
                    }
                }
            }
            //
            // 🔗 Links section.
            //
            Section("Links") {
                Link(destination: repositoryURL) {
                    Label("Source Code on GitHub", symbol: "􀫘")
                }
                Link(destination: twitterURL) {
                    Label("Author", symbol: "􀌫")
                }
                Link(destination: shareOnTwitterURL) {
                    Label("Share on Twitter", symbol: "􀉑")
                }
            }
        }
        //
        // ✋ Sign-in sheet.
        //
        .sheet(isPresented: $viewModel.isPresentLoginView) {
            LoginView()
        }
        //
        // 👋 Sign-out confirm sheet.
        //
        .confirmationDialog("Are you sign-out?", isPresented: $viewModel.isPresentLogoutConfirmSheet, titleVisibility: .visible) {
            Button("Sign-out", role: .destructive) {
                viewModel.onTapSignOutOnAlert()
            }
        }
    }
}

@MainActor
public final class SettingViewModel: ObservableObject {
    @Published var isSignIn = false
    @Published var isPresentLoginView = false
    @Published var isPresentLogoutConfirmSheet = false

    private var authState: AuthState

    public nonisolated init(
        authState: AuthState
    ) {
        self.authState = authState
    }

    // MARK: Events

    func onTapSignIn() {
        isPresentLogoutConfirmSheet = true
    }

    func onTapSignOut() {
        isPresentLoginView = true
    }

    func onTapSignOutOnAlert() {
        authState.logout()
    }
}
