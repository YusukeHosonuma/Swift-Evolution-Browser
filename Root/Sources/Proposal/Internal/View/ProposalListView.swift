//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/19.
//

import Foundation
import SwiftUI
import Core

struct ProposalListView: View {
    @Environment(\.scrollToTopID) var scrollToTopID
    
    let proposals: [Proposal]
    let onTapStar: (Proposal) -> ()

    var body: some View {
        if proposals.isEmpty {
            Text("No results found")
        } else {
            List {
                ForEach(proposals, id: \.id) { proposal in
                    NavigationLink {
                        ProposalDetailView(url: proposal.proposalURL)
                    } label: {
                        ProposalRowView(proposal: proposal, starTapped: {
                            onTapStar(proposal)
                        })
                    }
                    .contextMenu {
                        Link("Open in browser", destination: proposal.proposalURL)
                    }
                }
                .id(scrollToTopID)
            }
            .listStyle(.sidebar)
        }
    }
}
