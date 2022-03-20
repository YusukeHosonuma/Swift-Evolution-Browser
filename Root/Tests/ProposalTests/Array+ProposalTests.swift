//
//  Array+ProposalTests.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/20.
//

@testable import Proposal
import XCTest

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
        XCTAssertTrue([Proposal]().swiftVersions().isEmpty)
        XCTAssertEqual(["Swift 3.0", "Swift 4.0"], target.swiftVersions())
    }

    func test_search() throws {
        func search(by query: String) -> [String] {
            target.search(by: query).map(\.id)
        }

        // Common
        XCTAssertEqual(["SE-001"], search(by: "  A1  ")) // ✅ Trimming white spaces.
        XCTAssertTrue(search(by: "a1").isEmpty) // ⚠️ Not ignoring case. (currently)

        // ✅ Match `Swift version`
        XCTAssertEqual(["SE-001"], search(by: "Swift 3.0"))
        XCTAssertEqual(["SE-001"], search(by: "3.0"))
        XCTAssertEqual(["SE-002", "SE-003"], search(by: "Swift 4.0"))

        // ⚠️ Not match `Swift version`
        XCTAssertTrue(search(by: "Swift").isEmpty)

        // ✅ Match `title`
        XCTAssertEqual(["SE-001"], search(by: "A"))
        XCTAssertEqual(["SE-001", "SE-002"], search(by: "1"))
        XCTAssertEqual(["SE-003", "SE-004"], search(by: "2"))

        // ⚠️ Not match `title`
        XCTAssertTrue(search(by: "E").isEmpty)

        // ✅ Match `label`
        XCTAssertEqual(["SE-001", "SE-002", "SE-003"], search(by: "Implemented"))
        XCTAssertEqual(["SE-004"], search(by: "Accepted"))
    }

    func test_suggestions() throws {
        func suggestions(by query: String) -> [Suggestion] {
            target.suggestions(by: query)
        }

        // Empty
        XCTAssertEqual(
            [
                suggestion("Swift", "Swift "),
                suggestion("Accepted", "Accepted"),
                suggestion("Implemented", "Implemented"),
            ],
            suggestions(by: "")
        )

        // `Swift`
        XCTAssertEqual(
            [
                suggestion("Swift 3.0", "Swift 3.0"),
                suggestion("Swift 4.0", "Swift 4.0"),
            ],
            suggestions(by: "Swift")
        )

        // Match `Swift x.x`
        XCTAssertTrue(suggestions(by: "Swift 3.0").isEmpty)
        XCTAssertTrue(suggestions(by: "Swift 4.0").isEmpty)

        // Match `status`
        XCTAssertTrue(suggestions(by: "Accepted").isEmpty)
        XCTAssertTrue(suggestions(by: "Implemented").isEmpty)

        // ⚠️ Not implemented.
        // Partial match `status`
        // XCTAssertEqual(
        //     [
        //         suggestion("Accepted", "Accepted"),
        //     ],
        //     suggestions(by: "A")
        // )
    }
}
