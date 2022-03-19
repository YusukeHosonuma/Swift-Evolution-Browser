//
//  File.swift
//
//
//  Created by 細沼祐介 on 2022/03/11.
//

import Foundation

public extension Sequence {
    func asArray() -> [Element] {
        Array(self)
    }
}
