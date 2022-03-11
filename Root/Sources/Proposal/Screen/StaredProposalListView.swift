//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI
import Core

public struct StaredProposalListView<FirebaseAuthViewBuilder: FirebaseAuthViewBuildable>: View {
    
    private let _proposalStore: ProposalStore
    private let _firebaseAuthViewBuilder: FirebaseAuthViewBuilder

    public init(
        proposalStore: ProposalStore,
        firebaseAuthViewBuilder: FirebaseAuthViewBuilder
    ) {
        _proposalStore = proposalStore
        _firebaseAuthViewBuilder = firebaseAuthViewBuilder
    }
    
    public var body: some View {
        ProposalListView(
            firebaseAuthViewBuilder: _firebaseAuthViewBuilder,
            proposalFilter: { $0.star }
        )
        .navigationTitle("Stared")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
