//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/06.
//

import Foundation
import Combine
import FirebaseAuth
import Core

public final class FirebaseAuthState: AuthState, ObservableObject {
    public var user: CurrentValueSubject<Account?, Never> = .init(nil)
    public var isLogin: CurrentValueSubject<Bool, Never> = .init(false)

    private var _handle: AuthStateDidChangeListenerHandle!
    
    public init() {
        _handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user.send(
                user.map { Account(uid: $0.uid, name: $0.displayName ?? "") }
            )
            self.isLogin.send(user != nil)
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(_handle)
    }
    
    public func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            fatalError("\(error)") // TODO:
        }
    }
    
    public func authedPublisher<Output>(
        _ innerPublisher: @escaping (Account) -> AnyPublisher<Output, Error>,
        defaultValue: Output
    ) -> AnyPublisher<Output, Error> {
        user
            .flatMap { user -> AnyPublisher<Output, Error> in
                if let user = user {
                    return innerPublisher(user)
                } else {
                    return Just(defaultValue).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
