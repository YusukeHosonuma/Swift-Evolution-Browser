//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI
import Core

public struct StaredProposalListView: View {

    public init() {}
    
    public var body: some View {
        ProposalListView<StaredFilter>()
            #if os(iOS)
            .navigationTitle("Stared")
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}
