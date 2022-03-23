//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/04.
//

import Auth
import Combine
import Core
import Foundation

public enum ProposalData {
    case loading
    case error
    case success(proposals: [Proposal], searchHistories: [String])
}

@MainActor
public protocol ProposalDataSource {
    var proposals: CurrentValueSubject<ProposalData, Never> { get }

    func onInitialize() async
    func refresh() async throws
    func toggleStar(proposal: Proposal) async
    func addSearchHistory(_ keyword: String) async
}

@MainActor
public class ProposalDataSourceImpl: ProposalDataSource, ObservableObject {
    public var proposals: CurrentValueSubject<ProposalData, Never> = .init(.loading)

    private let proposalAPI: ProposalAPI
    private let userService: UserService
    private let latestProposals: PassthroughSubject<[Proposal]?, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []

    public nonisolated init(proposalAPI: ProposalAPI, userService: UserService) {
        self.proposalAPI = proposalAPI
        self.userService = userService
    }

    public func onInitialize() async {
        await latestProposals
            .combineLatest(userService.listen())
            .map { proposals, userData in
                guard let proposals = proposals else { return .error }
                return ProposalData.success(
                    proposals: proposals.map {
                        var proposal = $0
                        proposal.star = userData.stars.contains($0.id)
                        return proposal
                    },
                    searchHistories: userData.searchHistories
                )
            }
            .assign(to: \.value, on: proposals)
            .store(in: &cancellables)

        do {
            try await refresh()
        } catch {
            latestProposals.send(nil)
        }
    }

    public func refresh() async throws {
        let proposals = try await proposalAPI.fetch()
        latestProposals.send(proposals)
    }

    public func toggleStar(proposal: Proposal) async {
        do {
            try await userService.toggleStar(proposalID: proposal.id)
        } catch {
            preconditionFailure("\(error)")
        }
    }

    public func addSearchHistory(_ keyword: String) async {
        do {
            try await userService.addSearchHistory(keyword)
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
