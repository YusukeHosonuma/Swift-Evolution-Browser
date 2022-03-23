//
//  Array+ProposalTests.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/20.
//

@testable import Proposal
import XCTest
import SwiftParamTest
import Core

private let url = URL(string: "https://github.com/")!

// Create `Product`.
private func proposal(id: String, title: String, status: Proposal.Status) -> Proposal {
    .init(
        id: id,
        title: title,
        star: false,
        proposalURL: url,
        status: status
    )
}

// Create `Suggestion`.
private func suggestion(_ keyword: String, _ completion: String) -> Suggestion {
    .init(keyword: keyword, completion: completion)
}

final class RootTests: XCTestCase {
    private let target: [Proposal] = [
        proposal(id: "SE-001", title: "A1", status: .implemented(version: "3.0")),
        proposal(id: "SE-002", title: "B1", status: .implemented(version: "4.0")),
        proposal(id: "SE-003", title: "C2", status: .implemented(version: "4.0")),
        proposal(id: "SE-004", title: "D2", status: .accepted),
    ]

    // MARK: Tests

    func test_swiftVersions() throws {
        assert(to: [Proposal].swiftVersions) {
            args([Proposal](), expect: [String]())
            args(
                [
                    proposal(id: "", title: "", status: .implemented(version: "3.0")),
                    proposal(id: "", title: "", status: .implemented(version: "4.0")),
                    proposal(id: "", title: "", status: .implemented(version: "3.0")),
                ],
                expect: ["Swift 4.0", "Swift 3.0"]
            )
        }
    }

    func test_search() throws {
        func search(by query: String) -> [String] {
            target.search(by: query).map(\.id)
        }

        assert(to: search) {
            // 💡 Common
            args("  A1  ", expect: ["SE-001"]) // Trimming white spaces.
            args("a1",     expect: [String]()) // ⚠️ Not ignoring case. (currently)
            
            // 💡 Match category keywords.
            args("Swift", expect: target.map(\.id))
            args("Status", expect: target.map(\.id))

            // ✅ Match `Swift version`
            args("Swift 3.0", expect: ["SE-001"])
            args("3.0",       expect: ["SE-001"])
            args("Swift 4.0", expect: ["SE-002", "SE-003"])
            
            // ✅ Match `title`
            args("A", expect: ["SE-001"])
            args("1", expect: ["SE-001", "SE-002"])
            args("2", expect: ["SE-003", "SE-004"])
            
            // ⚠️ Not match `title`
            args("E", expect: [String]())

            // ✅ Match `label`
            args("Implemented", expect: ["SE-001", "SE-002", "SE-003"])
            args("Accepted",    expect: ["SE-004"])
            
            // ⚠️ Ignoring case is not supported. (currently)
            // args("accepted", expect: ["SE-004"])
        }
    }

    func test_suggestions() throws {
        func suggestions(by query: String) -> [Suggestion] {
            target.suggestions(by: query)
        }
        
        assert(to: suggestions) {
            // `Swift`
            args(
                "Swift",
                expect: [
                    suggestion("Swift 4.0", "Swift 4.0"),
                    suggestion("Swift 3.0", "Swift 3.0"),
                ]
            )
            
            // `Status`
            args(
                "Status",
                expect: [
                    suggestion("Accepted", "Accepted"),
                    suggestion("Implemented", "Implemented"),
                ]
            )

            // Match `Swift x.x`
            args("Swift 3.0", expect: [Suggestion]())
            args("Swift 4.0", expect: [Suggestion]())

            // Match `status`
            args("Accepted",    expect: [Suggestion]())
            args("Implemented", expect: [Suggestion]())
            
            // ⚠️ Partial match `status`. (not implemented currently)
            // args(
            //     "A",
            //     expect: [
            //         suggestion("Accepted", "Accepted"),
            //     ]
            // )
        }
        
        // let notIncludeImplemented: [Proposal] = [
        //     proposal(id: "SE-001", title: "", status: .accepted),
        //     proposal(id: "SE-002", title: "", status: .rejected),
        // ]
        //
        // XCTAssertEqual(
        //     notIncludeImplemented.suggestions(by: ""),
        //     [
        //         suggestion("Accepted", "Accepted"),
        //         suggestion("Rejected", "Rejected"),
        //     ],
        //     "Not include `Swift` suggestion."
        // )
    }
}
