//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/20.
//

#if os(iOS)
import SwiftUI

public struct ActivityView: UIViewControllerRepresentable {
    private let activityItems: [Any]
    private let applicationActivities: [UIActivity]?

    public init(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
    }

    public func makeUIViewController(context _: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    public func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
#endif
