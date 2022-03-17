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
    // TODO: Refactor
    var proposals: CurrentValueSubject<[ProposalEntity]?, Never> { get }
    func onInitialize() async
    func refresh() async
    func onTapStar(proposal: ProposalEntity) async
}

@MainActor
public class SharedProposal: ProposalStore, ObservableObject {
    public var proposals: CurrentValueSubject<[ProposalEntity]?, Never> = .init([])

    private let proposalAPI: ProposalAPI
    private let userService: UserService
    private var cancellables: Set<AnyCancellable> = []

    nonisolated public init(proposalAPI: ProposalAPI, authState: AuthState) {
        self.proposalAPI = proposalAPI
        self.userService = UserService(authState: authState)
    }

    public func onInitialize() async {
        await refresh()

        userService.listenStars()
            .map { [weak proposals] stars -> [ProposalEntity]? in
                guard let proposals = proposals?.value else { return nil }
                return proposals.map {
                    var proposal = $0
                    proposal.star = stars.contains($0.id)
                    return proposal
                }
            }
            .replaceError(with: nil)
            .assign(to: \.value, on: proposals)
            .store(in: &cancellables)
    }
    
    public func refresh() async {
        do {
            self.proposals.value = try await self.proposalAPI.fetch()
        } catch {
            self.proposals.value = nil
        }
    }
    
    public func onTapStar(proposal: ProposalEntity) async {
        do {
            if proposal.star {
                try await userService.removeStar(proposalID: proposal.id)
            } else {
                try await userService.addStar(proposalID: proposal.id)
            }
        } catch {
            print("Not logined!!") // TODO:
        }
    }
}
