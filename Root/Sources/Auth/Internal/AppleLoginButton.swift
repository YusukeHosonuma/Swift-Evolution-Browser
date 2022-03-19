//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/10.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Foundation
import SwiftUI

struct AppleLoginButton: View {
    @Binding var inProgress: Bool
    @State var currentNonce: String?

    private let completion: (Error?) -> Void

    init(inProgress: Binding<Bool>, completion: @escaping (Error?) -> Void) {
        _inProgress = inProgress
        self.completion = completion
    }

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: onRequest,
            onCompletion: onCompletion
        )
    }

    // MARK: Private Callback

    private func onRequest(request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)

        // Note:
        // とりあえず今は何も取得しない。
        // request.requestedScopes = [.fullName, .email]
    }

    private func onCompletion(result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            signIn(authorization: authorization)

        case let .failure(error):
            print("Sign in with Apple is failed. - \(error.localizedDescription)")
        }
    }

    // MARK: Private

    private func signIn(authorization: ASAuthorization) {
        inProgress = true

        // TODO: エラー処理は細かく精査してないので、とりあえず`fatalError`にして失敗した時にすぐに気付けるようにしておく。

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError()
        }

        guard let nonce = currentNonce else {
            print("Invalid state: A login callback was received, but no login request was sent.")
            fatalError()
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            fatalError()
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            fatalError()
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)

        Auth.auth().signIn(with: credential) { _, error in
            inProgress = false

            if let error = error as NSError? {
                print("Firebase sign-in is failure. - \(error.localizedDescription)")
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - Private Functions

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()

    return hashString
}
