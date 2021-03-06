//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/21.
//

import Foundation
import SFReadableSymbols
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
            Label(LocalizedStringKey("Open in Browser"), symbol: "􀆪")
        }
        Button {
            openURL(URL.searchInForums(proposalID: proposal.id))
        } label: {
            Label(LocalizedStringKey("Search in Forums"), symbol: "􀫊")
        }
        Button {
            openURL(URL.searchInTwitter(proposalID: proposal.id))
        } label: {
            Label(LocalizedStringKey("Search in Twitter"), symbol: "􀌫")
        }
    }
}
