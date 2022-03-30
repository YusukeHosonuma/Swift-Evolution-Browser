//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

#if os(macOS)

import SwiftUI

private let repositoryURL = URL(string: "https://github.com/YusukeHosonuma/Swift-Evolution-Browser")!

struct AboutView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: NSImage(named: "AppIcon")!)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)

            Text("\(Bundle.main.appName)")
                .font(.headline)
                .textSelection(.enabled)
                .padding(4)

            Text("Version \(Bundle.main.version) (\(Bundle.main.buildVersion))")
                .textSelection(.enabled)

            Link(repositoryURL.displayString, destination: repositoryURL)

            Text(Bundle.main.copyright)
                .multilineTextAlignment(.center)
        }
        .font(.caption)
        .padding(20)
        .frame(minWidth: 320, minHeight: 190)
    }
}

#endif
