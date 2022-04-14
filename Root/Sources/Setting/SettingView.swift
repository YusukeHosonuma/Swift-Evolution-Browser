//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/25.
//

import Auth
import Core
import Foundation
import Service
import SFReadableSymbols
import SwiftUI

private let privacyPolicyURL = URL(string: "https://yusukehosonuma.github.io/Swift-Evolution-Browser/privacy-policy")!

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
            Section(LocalizedStringKey("Account")) {
                if viewModel.isSignIn {
                    Button {
                        viewModel.onTapSignOut()
                    } label: {
                        Label(LocalizedStringKey("Sign-Out"), symbol: "􀉭")
                    }
                    Button {
                        Task {
                            await viewModel.onTapClearSearchHistory()
                        }
                    } label: {
                        Label(LocalizedStringKey("Clear search history"), symbol: "􀐫")
                    }
                    .disabled(viewModel.isDisabledClearSearchHistoryButton)
                } else {
                    Button {
                        viewModel.onTapSignIn()
                    } label: {
                        Label(LocalizedStringKey("Sign-In"), symbol: "􀉭")
                    }
                }
            }
            //
            // 🔗 Links section.
            //
            Section(LocalizedStringKey("Links")) {
                Link(destination: privacyPolicyURL) {
                    Label(LocalizedStringKey("Privacy Policy"), symbol: "􀉪")
                }
                Link(destination: repositoryURL) {
                    Label(LocalizedStringKey("Source Code on GitHub"), symbol: "􀫘")

                    // ☑️ Remove: GitHub icon is not allowed to change color.
                    // IconLabel("GitHub", icon: "github-icon", bundle: .module)
                }
                Link(destination: twitterURL) {
                    Label(LocalizedStringKey("Author"), symbol: "􀌫")
                }
                Link(destination: shareOnTwitterURL) {
                    Label(LocalizedStringKey("Share on Twitter"), symbol: "􀉑")
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
        .confirmationDialog(LocalizedStringKey("Are you sign-out?"), isPresented: $viewModel.isPresentLogoutConfirmSheet, titleVisibility: .visible) {
            Button(LocalizedStringKey("Sign-Out"), role: .destructive) {
                viewModel.onTapSignOutOnAlert()
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}

@MainActor
public final class SettingViewModel: ObservableObject {
    @Published var isSignIn = false
    @Published var isPresentLoginView = false
    @Published var isPresentLogoutConfirmSheet = false
    @Published var isDisabledClearSearchHistoryButton = false

    private let authState: AuthState
    private let userService: UserService
    private var initialized = false

    public nonisolated init(
        authState: AuthState,
        userService: UserService
    ) {
        self.authState = authState
        self.userService = userService
    }

    func onAppear() async {
        defer { initialized = true }
        guard initialized == false else { return }

        authState.$isLogin.assign(to: &$isSignIn)
        await userService.listen()
            .map(\.searchHistories.isEmpty)
            .assign(to: &$isDisabledClearSearchHistoryButton)
    }

    // MARK: Events

    func onTapSignIn() {
        isPresentLoginView = true
    }

    func onTapSignOut() {
        isPresentLogoutConfirmSheet = true
    }

    func onTapSignOutOnAlert() {
        authState.logout()
    }

    func onTapClearSearchHistory() async {
        if authState.isLogin {
            await userService.clearSearchHistory()
        }
    }
}
