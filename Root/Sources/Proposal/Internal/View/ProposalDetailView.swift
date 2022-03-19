//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/04.
//

import Foundation
import SwiftUI
import Core

struct ProposalDetailView: View {
    let url: URL
    
    @State private var isLoading: Bool = true
    
    var body: some View {
        ZStack {
            #if os(macOS)
            WebView(url: url, isLoading: $isLoading)
            #else
            WebView(url: url, isLoading: $isLoading)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Link(destination: url) {
                            Image(systemName: "globe")
                        }
                    }
                }
            #endif
            if isLoading {
                ProgressView()
            }
        }
    }
}
