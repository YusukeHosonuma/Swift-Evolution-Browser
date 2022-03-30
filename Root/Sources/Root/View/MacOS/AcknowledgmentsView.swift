//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import SwiftUI

private struct License: Identifiable {
    var id: String { title }
    let title: String
    let text: String
}

struct AcknowledgmentsView: View {
    private let licenses: [License] = loadLicenses()

    var body: some View {
        NavigationView {
            List(licenses) { license in
                NavigationLink {
                    TextEditor(text: .constant(license.text))
                } label: {
                    Text(license.title)
                }
            }
            .frame(minWidth: 200)
        }
        .frame(minWidth: 700, minHeight: 600)
    }
}

private func loadLicenses() -> [License] {
    guard
        let rootPath = Bundle.main.path(forResource: "Settings.bundle/com.mono0926.LicensePlist", ofType: "plist"),
        let rootDict = NSDictionary(contentsOfFile: rootPath) as? [String: Any],
        let xs = rootDict["PreferenceSpecifiers"] as? [[String: String]]
    else {
        preconditionFailure() // FIXME:
    }

    return xs.compactMap {
        guard
            let title = $0["Title"],
            let file = $0["File"],
            let path = Bundle.main.path(forResource: "Settings.bundle/\(file)", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
            let ys = dict["PreferenceSpecifiers"] as? [[String: String]],
            let text = ys.first?["FooterText"] else { return nil }
        return License(title: title, text: text)
    }
}
