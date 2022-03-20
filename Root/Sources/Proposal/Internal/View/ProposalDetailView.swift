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
    let url: URL

    @Environment(\.openURL) private var openURL

    @State private var isLoading = true
    @State private var isPresentSheet = false

    var body: some View {
        ZStack {
            #if os(macOS)
            WebView(url: url, isLoading: $isLoading)
            #else
            WebView(url: url, isLoading: $isLoading)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresentSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                openURL(url)
                            } label: {
                                Label("Open in browser", systemImage: "globe")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                .sheet(isPresented: $isPresentSheet) {
                    ActivityView(activityItems: [url])
                }
            #endif
            if isLoading {
                ProgressView()
            }
        }
    }
}
