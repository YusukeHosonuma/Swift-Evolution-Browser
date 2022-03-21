//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/04.
//

import Auth
import Combine
import Foundation

struct NotLoginedError: Error {}

public protocol UserService {
    func listenStars() async -> AnyPublisher<[String], Never>
    func addStar(proposalID: String) async throws
    func removeStar(proposalID: String) async throws
}

public final class UserServiceFirestore: UserService {
    private let authState: AuthState

    public init(authState: AuthState) {
        self.authState = authState
    }

    public func listenStars() async -> AnyPublisher<[String], Never> {
        await authState.authedPublisher(defaultValue: []) { user in
            UserDocument.publisher(user: user)
                .map(\.stars)
                .replaceError(with: [])
                .eraseToAnyPublisher()
        }
    }

    public func addStar(proposalID: String) async throws {
        guard let user = await authState.user else { throw NotLoginedError() }

        var doc = await UserDocument.get(user: user)
        doc.stars.append(proposalID)
        await doc.update()
    }

    public func removeStar(proposalID: String) async throws {
        guard let user = await authState.user else { throw NotLoginedError() }

        var doc = await UserDocument.get(user: user)
        doc.stars = doc.stars.filter { $0 != proposalID }
        await doc.update()
    }
}
