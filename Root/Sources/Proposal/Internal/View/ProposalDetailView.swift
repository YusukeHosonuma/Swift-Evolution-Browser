//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/04.
//

import Core
import FirebaseAnalytics
import Foundation
import SwiftUI

struct ProposalDetailView: View {
    private let proposal: Proposal
    @StateObject private var webViewState = WebViewState()

    init(proposal: Proposal) {
        self.proposal = proposal
    }

    var body: some View {
        ZStack {
            WebView(url: proposal.proposalURL, state: webViewState)
            if webViewState.isLoading {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: toolbarPlacement) {
                Spacer()
                Button {
                    webViewState.goBack()
                } label: {
                    Image(symbol: "􀯶")
                }
                .enabled(webViewState.canGoBack)

                Button {
                    webViewState.goForward()
                } label: {
                    Image(symbol: "􀯻")
                }
                .enabled(webViewState.canGoForward)
            }
        }
        .onAppear {
            // 💡 TODO: This is 1st example.
            Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                AnalyticsParameterItemID: "id-\(proposal.id)",
                AnalyticsParameterItemName: proposal.title,
                AnalyticsParameterContentType: "cont",
            ])
        }
    }

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
            .automatic
        #else
            .bottomBar
        #endif
    }
}
