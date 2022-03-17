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

public final class AuthState: ObservableObject {
    
    @Published public var user: Account? = nil
    @Published public var isLogin: Bool = false

    private var handle: AuthStateDidChangeListenerHandle!
    
    public init() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user.map { Account(uid: $0.uid, name: $0.displayName ?? "") }
            self.isLogin = user != nil
        }
    }
    
    deinit {
        Auth.auth().removeStateDidChangeListener(handle)
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
        $user
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
