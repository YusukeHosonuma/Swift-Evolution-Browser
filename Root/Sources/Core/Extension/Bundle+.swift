//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import Foundation

public extension Bundle {
    var appName: String {
        getInfo("CFBundleName")
    }

    var copyright: String {
        getInfo("NSHumanReadableCopyright")
    }

    var version: String {
        getInfo("CFBundleShortVersionString")
    }

    var buildVersion: String {
        getInfo("CFBundleVersion")
    }

    private func getInfo(_ key: String) -> String {
        infoDictionary?[key] as? String ?? ""
    }
}
