//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/10.
//

// FIXME: macOS は GoogleSignIn-iOS v6.2.0 のリリース待ち
// https://github.com/google/GoogleSignIn-iOS
#if os(iOS)

import Foundation
import FirebaseCore
import GoogleSignIn
import SwiftUI
import FirebaseAuth

struct GoogleLoginButton: View {

    var completion: (Error?) -> Void
    
    private var viewModel: GoogleLoginButtonViewModel = .init()
    
    init(completion: @escaping (Error?) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        GoogleLoginButtonInternal()
            .onTapGesture {
                Task {
                    do {
                        try await viewModel.onTap()
                        completion(nil)
                    } catch let error as GoogleLoginError {
                        switch error {
                        case .cancel:
                            completion(nil)
                        case .unknown:
                            completion(error)
                        }
                    }
                }
            }
    }
}

// MARK: File Private

fileprivate enum GoogleLoginError: Error {
    case cancel
    case unknown
}

@MainActor
fileprivate final class GoogleLoginButtonViewModel {

    nonisolated init() {}
    
    func onTap() async throws {
        let credential = try await fetchCredential()
        let _ = try await Auth.auth().signIn(with: credential)
    }

    // MARK: Private

    private func fetchCredential() async throws -> AuthCredential {
        guard let clientID = FirebaseApp.app()?.options.clientID else { fatalError() }
        
        let config = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { fatalError() }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { fatalError() }

        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { user, nsError in
                
                // 🚫 errors.
                // ref: https://developers.google.com/identity/sign-in/ios/reference/Enums/GIDSignInErrorCode
                if let nsError = nsError as? NSError {
                    let code = GoogleSignIn.GIDSignInError(_nsError: nsError).code
                    let error: GoogleLoginError
                    
                    switch code {
                    case .canceled:
                        error = .cancel
                        
                    default:
                        error = .unknown
                        break
                    }
                    
                    continuation.resume(throwing: error)
                    return
                }
                
                // ⚠️ not occur maybe.
                guard
                    let authentication = user?.authentication,
                    let idToken = authentication.idToken
                else {
                    fatalError()
                }
                
                // ✅ success.
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                continuation.resume(returning: credential)
            }
        }
    }
}

fileprivate struct GoogleLoginButtonInternal: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    private var button = GIDSignInButton()
    
    func makeUIView(context: Context) -> GIDSignInButton {
        button.colorScheme = colorScheme == .light ? .light : .dark
        return button
    }
    
    func updateUIView(_ uiView: GIDSignInButton, context: Context) {
        button.colorScheme = colorScheme == .light ? .light : .dark
    }
}

#endif
