//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/19.
//

import Core
import Foundation
import SwiftUI

struct ProposalListView: View {
    @Environment(\.scrollToTopID) var scrollToTopID

    let proposals: [Proposal]
    let onTapStar: (Proposal) -> Void

    var body: some View {
        if proposals.isEmpty {
            Text("No results found")
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 💡 検索サジェスチョンの領域が潰れる問題の対処
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
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
        }
    }
}
