//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/21.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseFirestoreSwift
import Foundation

public struct UserDocument: Codable {
    private static let maxSearchHistoryCount: Int = 5

    @DocumentID public var id: String?
    public private(set) var stars: [String]
    public private(set) var searchHistories: [String]

    public init(id: String? = nil, stars: [String], searchHistories: [String]) {
        self.id = id
        self.stars = stars
        self.searchHistories = searchHistories
    }

    public mutating func toggleStar(_ proposalID: String) {
        if stars.contains(proposalID) {
            stars = stars.filter { $0 != proposalID }
        } else {
            stars.append(proposalID)
        }
    }

    public mutating func addSearchHistory(_ keyword: String) {
        var xs = searchHistories
        xs.removeAll { $0 == keyword }
        xs.insert(keyword, at: 0)
        searchHistories = Array(xs.prefix(UserDocument.maxSearchHistoryCount))
    }
}

extension UserDocument {
    public static func get(user: User) async -> UserDocument {
        try! await ref(user: user)
            .getDocument()
            .data(as: UserDocument.self)
    }

    public static func publisher(user: User) -> AnyPublisher<UserDocument, Error> {
        ref(user: user)
            .snapshotPublisher()
            .map { snapshot in
                try! snapshot.data(as: UserDocument.self)
            }
            .eraseToAnyPublisher()
    }

    public func update() async {
        let data = try! Firestore.Encoder().encode(self)
        try! await ref().setData(data)
    }

    // MARK: Internal

    static func createNewUser(user: User) async {
        guard await isExists(user: user) == false else { return }
        await UserDocument(id: user.uid, stars: [], searchHistories: []).update()
    }

    static func isExists(user: User) async -> Bool {
        do {
            return try await ref(user: user)
                .getDocument()
                .exists
        } catch {
            // Note:
            // Permision error when not authed. (but this is work)
            return false
        }
    }

    // MARK: Private

    private func ref() -> DocumentReference {
        UserDocument.ref(id: id!)
    }

    private static func ref(user: User) -> DocumentReference {
        ref(id: user.uid)
    }

    private static func ref(id: String) -> DocumentReference {
        Firestore.firestore()
            .collection("users")
            .document(id)
    }
}
