//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/21.
//

import Foundation

public extension URL {
    static func searchInForums(proposalID: String) -> URL {
        URL(string: "https://forums.swift.org/search?q=\(proposalID)%20%23evolution")!
    }

    static func searchInTwitter(proposalID: String) -> URL {
        URL(string: "https://twitter.com/search?q=%22\(proposalID)%22")!
    }
}
