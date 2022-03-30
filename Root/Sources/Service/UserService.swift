//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/04.
//

import Auth
import Combine
import Core
import Foundation

public struct UserData {
    public var stars: [String]
    public var searchHistories: [String]

    public static var empty: UserData {
        .init(stars: [], searchHistories: [])
    }
}

public protocol UserService {
    func listen() async -> AnyPublisher<UserData, Never>
    func toggleStar(proposalID: String) async
    func addSearchHistory(_ keyword: String) async
    func clearSearchHistory() async
}

public final class UserServiceFirestore: UserService {
    private let authState: AuthState

    public init(authState: AuthState) {
        self.authState = authState
    }

    public func listen() async -> AnyPublisher<UserData, Never> {
        await authState.authedPublisher(defaultValue: .empty) { user in
            UserDocument.publisher(user: user)
                .map {
                    UserData(
                        stars: $0.stars,
                        searchHistories: $0.searchHistories ?? []
                    )
                }
                .replaceError(with: .empty)
                .eraseToAnyPublisher()
        }
    }

    public func toggleStar(proposalID: String) async {
        guard let user = await authState.user else { Logger.error(.loginIsNeeded); return }

        var doc = await UserDocument.get(user: user)
        doc.toggleStar(proposalID)
        await doc.update()
    }

    public func addSearchHistory(_ keyword: String) async {
        guard let user = await authState.user else { Logger.error(.loginIsNeeded); return }

        var doc = await UserDocument.get(user: user)
        doc.addSearchHistory(keyword)
        await doc.update()
    }

    public func clearSearchHistory() async {
        guard let user = await authState.user else { Logger.error(.loginIsNeeded); return }

        var doc = await UserDocument.get(user: user)
        doc.clearSearchHistory()
        await doc.update()
    }
}
