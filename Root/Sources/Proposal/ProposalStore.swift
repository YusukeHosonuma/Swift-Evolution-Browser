//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import Foundation
import Combine
import Core
import Auth

@MainActor
public protocol ProposalStore {
    var proposals: CurrentValueSubject<[ProposalEntity]?, Never> { get }
    func onInitialize() async
    func refresh() async throws
    func onTapStar(proposal: ProposalEntity) async
}

@MainActor
public class SharedProposal: ProposalStore, ObservableObject {
    
    // Note: `nil` is represent error.
    public var proposals: CurrentValueSubject<[ProposalEntity]?, Never> = .init([])

    private let proposalAPI: ProposalAPI
    private let userService: UserService
    private let latestProposals: PassthroughSubject<[ProposalEntity]?, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []

    nonisolated public init(proposalAPI: ProposalAPI, authState: AuthState) {
        self.proposalAPI = proposalAPI
        self.userService = UserService(authState: authState)
    }

    public func onInitialize() async {
        self.latestProposals
            .combineLatest(userService.listenStars().replaceError(with: []))
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
            try await self.refresh()
        } catch {
            latestProposals.send(nil)
        }
    }
    
    public func refresh() async throws {
        let proposals = try await self.proposalAPI.fetch()
        latestProposals.send(proposals)
    }
    
    public func onTapStar(proposal: ProposalEntity) async {
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
