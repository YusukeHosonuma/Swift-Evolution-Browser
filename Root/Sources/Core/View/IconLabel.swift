//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/27.
//

import SwiftUI

public struct IconLabel: View {
    private let title: String
    private let icon: String
    private let bundle: Bundle

    public init(_ title: String, icon: String, bundle: Bundle) {
        self.title = title
        self.icon = icon
        self.bundle = bundle
    }

    public var body: some View {
        Label {
            Text(title)
        } icon: {
            Image(icon, bundle: bundle)
                .resizable()
            #if os(macOS)
                .frame(width: 16, height: 16)
            #else
                .frame(width: 20, height: 20)
            #endif
        }
    }
}
