//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/06.
//

import Combine
import FirebaseAuth
import Foundation

@MainActor
public final class AuthState: ObservableObject {
    @Published public var user: User? = nil
    @Published public var isLogin: Bool = false

    public nonisolated init() {}

    public func onInitialize() async {
        // Note:
        // A `weak self` is not needed.
        // Because This class is not need to discard in app is running.
        Task {
            for await user in stateDidChangeStream() {
                if let user = user {
                    let authedUser = User(uid: user.uid, name: user.displayName ?? "")
                    await UserDocument.createNewUser(user: authedUser)
                    self.user = authedUser
                    self.isLogin = true
                } else {
                    self.user = nil
                    self.isLogin = false
                }
            }
        }
    }

    public func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            preconditionFailure("\(error)")
        }
    }

    public func authedPublisher<Output>(
        defaultValue: Output,
        innerPublisher: @escaping (User) -> AnyPublisher<Output, Never>
    ) -> AnyPublisher<Output, Never> {
        $user
            .flatMap { user -> AnyPublisher<Output, Never> in
                if let user = user {
                    return innerPublisher(user)
                } else {
                    return Just(defaultValue).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private

    private func stateDidChangeStream() -> AsyncStream<FirebaseAuth.User?> {
        AsyncStream { continuation in
            Auth.auth().addStateDidChangeListener { _, user in
                continuation.yield(user)
            }
        }
    }
}
