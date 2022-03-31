//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/03.
//

import Foundation

public struct Proposal: Equatable {
    public var id: String
    public var title: String
    public var star: Bool
    public var proposalURL: URL
    public var status: Status

    public init(id: String, title: String, star: Bool, proposalURL: URL, status: Proposal.Status) {
        self.id = id
        self.title = title
        self.star = star
        self.proposalURL = proposalURL
        self.status = status
    }

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
            .unknown,
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
        case unknown

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
            case .implemented:
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
            case .unknown:
                return "-"
            }
        }
    }
}
