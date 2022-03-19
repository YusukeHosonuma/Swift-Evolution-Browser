//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/08.
//

import Foundation
import SwiftUI

public struct ScrollToTopID: EnvironmentKey {
    public static var defaultValue: String { "" }
}

public extension EnvironmentValues {
    var scrollToTopID: String {
        get {
            self[ScrollToTopID.self]
        }
        set {
            self[ScrollToTopID.self] = newValue
        }
    }
}
