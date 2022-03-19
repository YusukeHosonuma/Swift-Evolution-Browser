//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/08.
//

import Foundation

public struct Account {
    public var uid: String
    public var name: String

    public init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}
