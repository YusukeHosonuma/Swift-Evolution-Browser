

import Auth
import Core
import Foundation
import NeedleFoundation
import Proposal
import SwiftUI
import Root

// swiftlint:disable unused_declaration
private let needleDependenciesHash : String? = nil

// MARK: - Registration

public func registerProviderFactories() {
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent->ProposalComponent") { component in
        return ProposalDependencyb6a3199fb61729d3a8eeProvider(component: component)
    }
    __DependencyProviderRegistry.instance.registerDependencyProviderFactory(for: "^->RootComponent") { component in
        return EmptyDependencyProvider(component: component)
    }
    
}

// MARK: - Providers

private class ProposalDependencyb6a3199fb61729d3a8eeBaseProvider: ProposalDependency {
    var authState: AuthState {
        return rootComponent.authState
    }
    private let rootComponent: RootComponent
    init(rootComponent: RootComponent) {
        self.rootComponent = rootComponent
    }
}
/// ^->RootComponent->ProposalComponent
private class ProposalDependencyb6a3199fb61729d3a8eeProvider: ProposalDependencyb6a3199fb61729d3a8eeBaseProvider {
    init(component: NeedleFoundation.Scope) {
        super.init(rootComponent: component.parent as! RootComponent)
    }
}
