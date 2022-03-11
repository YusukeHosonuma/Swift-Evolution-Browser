//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import Foundation
import Combine
import Core


@MainActor
public protocol ProposalStore {
    var proposals: CurrentValueSubject<[ProposalEntity], Never> { get }
    func onInitialize() async
    func onTapStar(proposal: ProposalEntity) async
}


@MainActor
public class SharedProposal: ProposalStore, ObservableObject {
    
    private let proposalAPI: ProposalAPI
    private let userService: UserService

    nonisolated public init(proposalAPI: ProposalAPI, authState: AuthState) {
        self.proposalAPI = proposalAPI
        self.userService = UserService(authState: authState)
    }

    public var proposals: CurrentValueSubject<[ProposalEntity], Never> = .init([])
    
    @Published var proposals2: [ProposalEntity] = []
    
    private var _cancellables: Set<AnyCancellable> = []
    
    public func onInitialize() async {
        
        do {
            self.proposals.value =  try await self.proposalAPI.fetch()
        } catch {
            fatalError() // TODO:
        }
        
        //
        // ⭐ `Combine` version:
        //
        userService.listenStars()
            .map { [weak self] stars -> [ProposalEntity] in
                guard let self = self else { return [] }
                return self.proposals.value.map {
                    var proposal = $0
                    proposal.star = stars.contains($0.id)
                    return proposal
                }
            }
            .replaceError(with: [])  // replace error.
            .assign(to: \.value, on: proposals) // connect `@Published`.
            .store(in: &_cancellables)
        
        //
        // ⭐ `for-await` version:
        //
//        let s = userService.listenStars().asAsyncStream()
//        Task {
//            do {
//                for try await stars in userService.listenStars().asAsyncStream() {
//                    self.proposals = self.proposals.map { // assign directory.
//                        var proposal = $0
//                        proposal.star = stars.contains($0.id)
//                        return proposal
//                    }
//                }
//                print("⭐ finish!")
//            } catch {
//                self.proposals = [] // assign directory.
//            }
//        }
//
//        Task {
//            try! await Task.sleep(nanoseconds: 1_000_000_0000)
//            s.cancel()
//        }
        
//        let task = Task { [weak self] in
//            do {
//                for try await stars in userService.listenStars().values {
//                    guard let self = self else { return }
//                    self.proposals = self.proposals.map { // assign directory.
//                        var proposal = $0
//                        proposal.star = stars.contains($0.id)
//                        return proposal
//                    }
//                }
//            } catch {
//                guard let self = self else { return }
//                self.proposals = [] // assign directory.
//            }
//        }
//        _cancellables.insert(.init { task.cancel() } )

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
