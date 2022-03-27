//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/04.
//

import Core
import Foundation
import SwiftUI

struct ProposalDetailView: View {
    private let url: URL
    @StateObject private var webViewState = WebViewState()

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        ZStack {
            WebView(url: url, state: webViewState)
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
    }

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
            .automatic
        #else
            .bottomBar
        #endif
    }
}
