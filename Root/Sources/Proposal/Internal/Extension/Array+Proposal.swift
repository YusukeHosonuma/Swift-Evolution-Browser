//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/18.
//

import Algorithms
import Core
import Foundation

extension Array where Element == Proposal {
    func swiftVersions() -> [String] {
        compactMap {
            if case let .implemented(version) = $0.status {
                return version.isEmpty ? nil : "Swift \(version)"
            } else {
                return nil
            }
        }
        .uniqued()
        .sorted { $0 > $1 }
    }

    func statusLabels() -> [String] {
        map(\.status.label).uniqued().sorted()
    }

    func isMatchKeyword(query: String) -> Bool {
        swiftVersions().contains(query) || statusLabels().contains(query)
    }

    func search(by query: String) -> [Proposal] {
        // ⚠️ Note:
        // Not ignoring case currently.

        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        func isVersionMatch(_ proposal: Proposal) -> Bool {
            guard case let .implemented(version) = proposal.status else { return false }

            var versionString = query
            if query.contains("Swift"), let last = query.split(separator: " ").last {
                versionString = String(last)
            }
            return version == versionString
        }

        if query.isEmpty {
            return self
        } else {
            return filter {
                $0.title.contains(query) ||
                    $0.status.label == query ||
                    isVersionMatch($0)
            }
        }
    }

    func suggestions(by query: String) -> [Suggestion] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)

        let statusLabels = statusLabels()
        let swiftVersions = swiftVersions()

        if swiftVersions.contains(query) || statusLabels.contains(query) {
            return []
        }

        if query.contains("Swift") {
            return swiftVersions.map { Suggestion(keyword: $0, completion: $0) }
        } else {
            let head = swiftVersions.isEmpty ? [] : [Suggestion(keyword: "Swift", completion: "Swift ")]
            return head + statusLabels.map { Suggestion(keyword: $0, completion: $0) }
        }
    }
}
