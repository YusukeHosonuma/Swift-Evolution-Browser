//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/18.
//

import Foundation
import Algorithms

extension Array where Element == Proposal {

    func swiftVersions() -> [String] {
        compactMap {
            if case .implemented(let version) = $0.status {
                return version.isEmpty ? nil : "Swift \(version)"
            } else {
                return nil
            }
        }
        .uniqued()
        .asArray()
    }
    
    func apply(query: String) -> [Proposal] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        func isVersionMatch(_ proposal: Proposal) -> Bool {
            guard case .implemented(let version) = proposal.status else { return false }
            
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
}
