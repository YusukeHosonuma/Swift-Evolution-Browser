//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/04.
//

import Auth
import Combine
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseFirestoreSwift
import Foundation

private struct UserDocument: Codable {
    @DocumentID var id: String?
    var stars: [String]
}

struct NotLoginedError: Error {}

public protocol UserService {
    func listenStars() -> AnyPublisher<[String], Never>
    func addStar(proposalID: String) async throws
    func removeStar(proposalID: String) async throws
}

public final class UserServiceFirestore: UserService {
    private let authState: AuthState

    public init(authState: AuthState) {
        self.authState = authState
    }

    public func listenStars() -> AnyPublisher<[String], Never> {
        authState.authedPublisher({ user in
            self.userDocumentRef(user: user)
                .snapshotPublisher()
                .map { snapshot -> [String] in
                    do {
                        // 🙋‍♂️ Create user if need.
                        guard snapshot.exists else {
                            let data = try Firestore.Encoder().encode(UserDocument(stars: []))
                            snapshot.reference.setData(data) { _ in }
                            return []
                        }

                        let document = try snapshot.data(as: UserDocument.self)
                        return document.stars
                    } catch {
                        preconditionFailure("\(error)")
                    }
                }
                .replaceError(with: [])
                .eraseToAnyPublisher()
        }, defaultValue: [])
    }

    public func addStar(proposalID: String) async throws {
        guard let user = authState.user else { throw NotLoginedError() }

        try await userDocumentRef(user: user)
            .updateDocument { (document: inout UserDocument) in
                document.stars.append(proposalID)
            }
    }

    public func removeStar(proposalID: String) async throws {
        guard let user = authState.user else { throw NotLoginedError() }

        try await userDocumentRef(user: user)
            .updateDocument { (document: inout UserDocument) in
                document.stars = document.stars.filter { $0 != proposalID }
            }
    }

    // MARK: Private

    private func userDocumentRef(user: Account) -> DocumentReference {
        Firestore.firestore().collection("users").document(user.uid)
    }
}

private extension DocumentReference {
    func updateDocument<T: Codable>(update: (inout T) -> Void) async throws {
        var document = try await getDocument().data(as: T.self)
        update(&document)
        let data = try Firestore.Encoder().encode(document)
        try await setData(data)
    }
}
