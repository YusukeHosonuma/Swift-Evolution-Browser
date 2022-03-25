//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/25.
//

import Auth
import Foundation
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

struct SettingView: View {
    @EnvironmentObject private var authState: AuthState

    @State private var isPresentLoginView = false
    @State private var isPresentLogoutConfirmSheet = false

    var body: some View {
        List {
            //
            // Account section.
            //
            Section("Account") {
                if authState.isLogin {
                    Button {
                        isPresentLogoutConfirmSheet = true
                    } label: {
                        Label("Sign-out", systemImage: "person.crop.circle")
                    }
                } else {
                    Button {
                        isPresentLoginView = true
                    } label: {
                        Label("Sign-in", systemImage: "person.crop.circle")
                    }
                }
            }
            //
            // Links section.
            //
            Section("Links") {
                Link(destination: repositoryURL) {
                    Label("Source Code on GitHub", systemImage: "text.book.closed.fill")
                }
                Link(destination: twitterURL) {
                    Label("Author", systemImage: "bubble.left.fill")
                }
                Link(destination: shareOnTwitterURL) {
                    Label("Share on Twitter", systemImage: "arrowshape.turn.up.right.fill")
                }
            }
        }
        //
        // Sign-in sheet.
        //
        .sheet(isPresented: $isPresentLoginView) {
            LoginView()
        }
        //
        // Sign-out confirm sheet.
        //
        .confirmationDialog("Are you sign-out?", isPresented: $isPresentLogoutConfirmSheet, titleVisibility: .visible) {
            Button("Sign-out", role: .destructive) {
                authState.logout()
            }
        }
    }
}
