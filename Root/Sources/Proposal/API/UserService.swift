//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import Core
import Auth

struct UserDocument: Codable {
    @DocumentID var id: String?
    var stars: [String]
}

struct NotLoginedError: Error {}

final class UserService {
    private let _authState: AuthState
    
    init(authState: AuthState) {
        _authState = authState
    }
    
    func listenStars() -> AnyPublisher<[String], Never> {
        _authState.authedPublisher({ user in
            self._userDocumentRef(user: user)
                .snapshotPublisher()
                .map { snapshot -> [String] in
                    do {
                        // Create user if need.
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
    
    func addStar(proposalID: String) async throws {
        guard let user = _authState.user else { throw NotLoginedError() }

        try await _userDocumentRef(user: user).updateDocument { (document: inout UserDocument) in
            document.stars.append(proposalID)
        }
    }
    
    func removeStar(proposalID: String) async throws {
        guard let user = _authState.user else { throw NotLoginedError() }
        
        try await _userDocumentRef(user: user).updateDocument { (document: inout UserDocument) in
            document.stars = document.stars.filter { $0 != proposalID }
        }
    }
    
    // MARK: Private
    
    private func _userDocumentRef(user: Account) -> DocumentReference {
        Firestore.firestore().collection("users").document(user.uid)
    }
}

extension DocumentReference {
    func updateDocument<T: Codable>(update: (inout T) -> ()) async throws {
        var document = try await self.getDocument().data(as: T.self)
        update(&document)
        let data = try Firestore.Encoder().encode(document)
        try await self.setData(data)
    }
}
