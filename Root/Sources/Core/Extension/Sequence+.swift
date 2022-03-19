//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/11.
//

import Foundation

public extension Sequence {
    func asArray() -> [Element] {
        Array(self)
    }
}
