//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/18.
//

import Foundation

public extension URLSessionConfiguration {
    static let shared: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default

        // Always fetch latest json.
        config.requestCachePolicy = .reloadIgnoringLocalCacheData

        // 🪲 for debug:
        // config.waitsForConnectivity = false
        // config.timeoutIntervalForRequest = 3

        return config
    }()
}
