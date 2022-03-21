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

    @State private var isLoading = true

    var body: some View {
        ZStack {
            WebView(url: url, isLoading: $isLoading)
            if isLoading {
                ProgressView()
            }
        }
    }
}
