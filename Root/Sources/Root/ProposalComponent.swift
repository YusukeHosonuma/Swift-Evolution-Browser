//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/08.
//

import Foundation
import NeedleFoundation
import SwiftUI
import Core
import Proposal

public protocol ProposalDependency: Dependency {
    var authState: AuthState { get }
}

public final class ProposalComponent: Component<ProposalDependency> {
    
    public var proposalStore: ProposalStore {
        shared {
            SharedProposal(
                proposalAPI: proposalAPI,
                authState: dependency.authState
            )
        }
    }
    
    private var proposalAPI: ProposalAPI {
        shared { ProposalAPIClient() }
    }
}

extension ProposalComponent {
    public func onInitialize() async {
        await proposalStore.onInitialize()
    }
}
