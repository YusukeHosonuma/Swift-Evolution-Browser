//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/21.
//

import Foundation
import SwiftUI

public struct ProposalMenu: View {
    @Environment(\.openURL) private var openURL

    private let proposal: Proposal

    public init(proposal: Proposal) {
        self.proposal = proposal
    }

    public var body: some View {
        Button {
            openURL(proposal.proposalURL)
        } label: {
            Label("Open in Browser", systemImage: "globe")
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
    }
}
