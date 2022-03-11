//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/11.
//

import Foundation

extension Array where Element: Hashable {
    public func uniqued() -> [Element] {
        var set: Set<Iterator.Element> = []
        return filter { set.insert($0).inserted }
    }
}
