//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/03.
//

import Foundation

private let proposalsURL = URL(string: "https://data.swift.org/swift-evolution/proposals")!

private let decoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    return jsonDecoder
}()

public final class ProposalClient {
    private let config: URLSessionConfiguration

    public init(config: URLSessionConfiguration = .default) {
        self.config = config
    }

    public func fetch() async throws -> [Proposal] {
        let session = URLSession(configuration: config)

        let (data, _) = try await session.data(for: URLRequest(url: proposalsURL))
        return try decoder.decode([Proposal].self, from: data)
    }
}
