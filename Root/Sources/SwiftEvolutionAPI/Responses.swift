// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let proposal = try? newJSONDecoder().decode(Proposal.self, from: jsonData)

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

// MARK: - ProposalElement
public struct Proposal: Codable, Equatable {
    public var authors: [ReviewManager]
    public var id: String
    public var link: String
    public var reviewManager: ReviewManager
    public var sha: String
    public var status: StatusClass
    public var summary: String
    public var title: String
    public var trackingBugs: [TrackingBug]?
    public var warnings: [Warning]?
    public var implementation: [Implementation]?

    enum CodingKeys: String, CodingKey {
        case authors
        case id
        case link
        case reviewManager
        case sha
        case status
        case summary
        case title
        case trackingBugs
        case warnings
        case implementation
    }

    public init(authors: [ReviewManager], id: String, link: String, reviewManager: ReviewManager, sha: String, status: StatusClass, summary: String, title: String, trackingBugs: [TrackingBug]?, warnings: [Warning]?, implementation: [Implementation]?) {
        self.authors = authors
        self.id = id
        self.link = link
        self.reviewManager = reviewManager
        self.sha = sha
        self.status = status
        self.summary = summary
        self.title = title
        self.trackingBugs = trackingBugs
        self.warnings = warnings
        self.implementation = implementation
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - ReviewManager
public struct ReviewManager: Codable, Equatable {
    public var link: String
    public var name: String

    enum CodingKeys: String, CodingKey {
        case link
        case name
    }

    public init(link: String, name: String) {
        self.link = link
        self.name = name
    }
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Implementation
public struct Implementation: Codable, Equatable {
    public var account: Account
    public var id: String
    public var repository: Repository
    public var type: TypeEnum

    enum CodingKeys: String, CodingKey {
        case account
        case id
        case repository
        case type
    }

    public init(account: Account, id: String, repository: Repository, type: TypeEnum) {
        self.account = account
        self.id = id
        self.repository = repository
        self.type = type
    }
}

public enum Account: String, Codable, Equatable {
    case apple = "apple"
}

public enum Repository: String, Codable, Equatable {
    case swift = "swift"
    case swiftCorelibsFoundation = "swift-corelibs-foundation"
    case swiftPackageManager = "swift-package-manager"
    case swiftXcodePlaygroundSupport = "swift-xcode-playground-support"
}

public enum TypeEnum: String, Codable, Equatable {
    case commit = "commit"
    case pull = "pull"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - StatusClass
public struct StatusClass: Codable, Equatable {
    public var state: State?
    public var version: String?
    public var end: String?
    public var start: String?

    enum CodingKeys: String, CodingKey {
        case state
        case version
        case end
        case start
    }

    public init(state: State, version: String?, end: String?, start: String?) {
        self.state = state
        self.version = version
        self.end = end
        self.start = start
    }
}

public enum State: String, Codable, Equatable {
    case accepted = ".accepted"
    case activeReview = ".activeReview"
    case awaitingReview = ".awaitingReview"
    case deferred = ".deferred"
    case implemented = ".implemented"
    case previewing = ".previewing"
    case rejected = ".rejected"
    case returnedForRevision = ".returnedForRevision"
    case withdrawn = ".withdrawn"
    case scheduledForReview = ".scheduledForReview"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - TrackingBug
public struct TrackingBug: Codable, Equatable {
    public var assignee: String
    public var id: String
    public var link: String
    public var radar: String
    public var resolution: Resolution
    public var status: StatusEnum
    public var title: String
    public var updated: String

    enum CodingKeys: String, CodingKey {
        case assignee
        case id
        case link
        case radar
        case resolution
        case status
        case title
        case updated
    }

    public init(assignee: String, id: String, link: String, radar: String, resolution: Resolution, status: StatusEnum, title: String, updated: String) {
        self.assignee = assignee
        self.id = id
        self.link = link
        self.radar = radar
        self.resolution = resolution
        self.status = status
        self.title = title
        self.updated = updated
    }
}

public enum Resolution: String, Codable, Equatable {
    case done = "Done"
    case duplicate = "Duplicate"
    case empty = ""
    case wonTDo = "Won't Do"
}

public enum StatusEnum: String, Codable, Equatable {
    case closed = "Closed"
    case empty = ""
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case statusOpen = "Open"
}

//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

// MARK: - Warning
public struct Warning: Codable, Equatable {
    public var kind: String
    public var message: String
    public var stage: String

    enum CodingKeys: String, CodingKey {
        case kind
        case message
        case stage
    }

    public init(kind: String, message: String, stage: String) {
        self.kind = kind
        self.message = message
        self.stage = stage
    }
}
