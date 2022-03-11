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
        .navigationTitle("All")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
