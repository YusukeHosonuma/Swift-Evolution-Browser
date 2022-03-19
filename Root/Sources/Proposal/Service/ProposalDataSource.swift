//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/04.
//

import Auth
import Combine
import Core
import Foundation

@MainActor
public protocol ProposalDataSource {
    var proposals: CurrentValueSubject<[Proposal]?, Never> { get }

    func onInitialize() async
    func refresh() async throws
    func toggleStar(proposal: Proposal) async
}

@MainActor
public class ProposalDataSourceImpl: ProposalDataSource, ObservableObject {
    // Note: `nil` is represent error.
    public var proposals: CurrentValueSubject<[Proposal]?, Never> = .init([])

    private let proposalAPI: ProposalAPI
    private let userService: UserService
    private let latestProposals: PassthroughSubject<[Proposal]?, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []

    public nonisolated init(proposalAPI: ProposalAPI, userService: UserService) {
        self.proposalAPI = proposalAPI
        self.userService = userService
    }

    public func onInitialize() async {
        latestProposals
            .combineLatest(userService.listenStars())
            .map { proposals, stars in
                guard let proposals = proposals else { return nil }
                return proposals.map {
                    var proposal = $0
                    proposal.star = stars.contains($0.id)
                    return proposal
                }
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
            if proposal.star {
                try await userService.removeStar(proposalID: proposal.id)
            } else {
                try await userService.addStar(proposalID: proposal.id)
            }
        } catch {
            preconditionFailure("\(error)")
        }
    }
}
