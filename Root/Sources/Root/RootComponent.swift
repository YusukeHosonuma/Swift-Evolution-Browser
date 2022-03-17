//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/02/25.
//

import Foundation
import NeedleFoundation
import SwiftUI
import Core
import Auth
import Proposal

public final class RootComponent: BootstrapComponent {

    public func makeView() -> some View {
        RootView()
    }

    // Global objects
    
//    public var authState: AuthState {
//        shared { FirebaseAuthState() }
//    }
    
    // MARK: Chiild components
    
    public var proposalComponent: ProposalComponent {
        shared { ProposalComponent.init(parent: self) }
    }
}

extension RootComponent {
    public func onInitialize() async {
        await proposalComponent.onInitialize()
    }
}
