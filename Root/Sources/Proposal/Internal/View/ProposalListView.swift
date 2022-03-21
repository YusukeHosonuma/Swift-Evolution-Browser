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
    @Environment(\.openURL) private var openURL

    let proposals: [Proposal]
    let onTapStar: (Proposal) -> Void

    @State private var isPresentActivitySheet = false

    var body: some View {
        if proposals.isEmpty {
            Text("No results found")
                .frame(maxWidth: .infinity, maxHeight: .infinity) // 💡 検索サジェスチョンの領域が潰れる問題の対処
        } else {
            List {
                ForEach(proposals, id: \.id) { proposal in
                    ZStack {
                        NavigationLink {
                            ProposalDetailView(url: proposal.proposalURL)
                            #if os(iOS)
                                // 💡 Navigation 下部に余白が表示される問題の対処
                                .navigationBarTitleDisplayMode(.inline)
                            #endif
                                .toolbar {
                                    toolbar(proposal: proposal)
                                }
                                .sheet(isPresented: $isPresentActivitySheet) {
                                    ActivityView(activityItems: [proposal.proposalURL])
                                }
                        } label: {
                            EmptyView()
                        }
                        .opacity(0)
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

    @ToolbarContentBuilder
    private func toolbar(proposal: Proposal) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isPresentActivitySheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    openURL(proposal.proposalURL)
                } label: {
                    Label("Open in browser", systemImage: "globe")
                }
                Button {
                    openURL(URL.searchInForums(proposalID: proposal.id))
                } label: {
                    Label("Search in Forums", systemImage: "swift")
                }
                Button {
                    openURL(URL.searchInTwitter(proposalID: proposal.id))
                } label: {
                    Text("Search in Twitter")
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}
