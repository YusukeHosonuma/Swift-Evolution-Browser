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
        RootView(component: self)
    }

    // Global objects
    
    public var authState: AuthState {
        shared { FirebaseAuthState() }
    }
    
    // Builder provider
        
    public var firebaseAuthViewBuilderProvidable: FirebaseAuthViewBuilderProvidable {
        shared { FirebaseAuthViewBuilderProvider() }
    }
    
    // MARK: Chiild components
    
    public var proposalComponent: ProposalComponent {
        shared { ProposalComponent.init(parent: self) }
    }
    
    public var loginComponent: LoginComponent {
        shared { LoginComponent.init(parent: self) }
    }
}

public class FirebaseAuthViewBuilder: FirebaseAuthViewBuildable {
    public func makeView(_ input: Binding<Bool>) -> some View {
        LoginView()
    }
}

public protocol FirebaseAuthViewBuilderProvidable {
    var builder: FirebaseAuthViewBuilder { get }
}

public class FirebaseAuthViewBuilderProvider: FirebaseAuthViewBuilderProvidable {
    public var builder: FirebaseAuthViewBuilder {
        .init()
    }
}

public final class LoginComponent: Component<EmptyDependency> {
    public var firebaseAuthViewBuilder: FirebaseAuthViewBuilder {
        .init()
    }
}

extension RootComponent {
    public func onInitialize() async {
        await proposalComponent.onInitialize()
    }
}
