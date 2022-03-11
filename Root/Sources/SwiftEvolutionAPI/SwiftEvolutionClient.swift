//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/03.
//

import Foundation

private let _proposalsURL = URL(string: "https://data.swift.org/swift-evolution/proposals")!

private let _decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    return jsonDecoder
}()

public final class SwiftEvolutionProposalClient {

    public init() {}
    
    public func fetch() async throws -> [Proposal] {
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: _proposalsURL))
        return try _decoder.decode([Proposal].self, from: data)
    }
}
