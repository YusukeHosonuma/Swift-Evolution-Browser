//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/03.
//

import Foundation
import SwiftEvolutionAPI

public protocol ProposalAPI {
    func fetch() async throws -> [ProposalEntity]
}

public final class ProposalAPIClient: ProposalAPI {
    private let _client = SwiftEvolutionProposalClient()
    
    public init() {}
    
    public func fetch() async throws -> [ProposalEntity] {
        let proposals = try await _client.fetch()
        return proposals.map {
            ProposalEntity(
                id: $0.id,
                title: $0.title.trimmingCharacters(in: .whitespaces),
                star: false,
                proposalURL: URL(string: "https://github.com/apple/swift-evolution/blob/main/proposals/\($0.link)")!,
                status: convertStatus(status: $0.status)
            )
        }.reversed()
    }
    
    func convertStatus(status: StatusClass) -> ProposalEntity.Status {
        switch status.state {
        case .accepted:
            return .accepted
        case .activeReview:
            return .activeReview
        case .awaitingReview:
            return .awaitingReview
        case .deferred:
            return .deferred
        case .implemented:
            return .implemented(version: status.version ?? "-")
        case .previewing:
            return .previewing
        case .rejected:
            return .rejected
        case .returnedForRevision:
            return .returnedForRevision
        case .withdrawn:
            return .withdrawn
        case .scheduledForReview:
            return .scheduledForReview
        }
    }
}
