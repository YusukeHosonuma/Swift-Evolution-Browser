//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI
import Core

public struct AllProposalListView: View {
    
    public init() {}
    
    public var body: some View {
        ProposalListView(
            proposalFilter: { _ in true }
        )
        #if os(iOS)
        .navigationTitle("All")
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
