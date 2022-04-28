//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/04/28.
//

import Foundation

public extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
