//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import SwiftUI
import Core

public struct StaredProposalListView: View {

    private let scrollToTopID: String
    
    public init(scrollToTopID: String) {
        self.scrollToTopID = scrollToTopID
    }
    
    public var body: some View {
        ProposalListContainerView<StaredFilter>(scrollToTopID: scrollToTopID)
    }
}
