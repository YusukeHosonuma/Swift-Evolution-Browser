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
    
    var body: some View {
        #if os(macOS)
        WebView(url: url)
        #else
        WebView(url: url)
            .navigationBarHidden(true)
        #endif
    }
}
