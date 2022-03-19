//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/03.
//

import Foundation

public struct Proposal: Equatable {
    var id: String
    var title: String
    var star: Bool
    var proposalURL: URL
    var status: Status

    public enum Status: Codable, CaseIterable, Comparable {
        public static var allCases: [Proposal.Status] = [
            .accepted,
            .activeReview,
            .awaitingReview,
            .deferred,
            .implemented(version: ""),
            .previewing,
            .rejected,
            .returnedForRevision,
            .withdrawn,
            .scheduledForReview,
        ]
        
        case accepted
        case activeReview
        case awaitingReview
        case deferred
        case implemented(version: String)
        case previewing
        case rejected
        case returnedForRevision
        case withdrawn
        case scheduledForReview
        
        public var label: String {
            switch self {
            case .accepted:
                return "Accepted"
            case .activeReview:
                return "Active Review"
            case .awaitingReview:
                return "Awaiting Review"
            case .deferred:
                return "Deferred"
            case .implemented(_):
                return "Implemented"
            case .previewing:
                return "Previewing"
            case .rejected:
                return "Rejected"
            case .returnedForRevision:
                return "Returned"
            case .withdrawn:
                return "Withdrawn"
            case .scheduledForReview:
                return "Scheduled for Review"
            }
        }
    }
}
