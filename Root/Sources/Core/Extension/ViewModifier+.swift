//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/25.
//

import Foundation
import SwiftUI

public extension ViewModifier {
    #if os(macOS)
    func toggleSidebar() {
        NSApplication.toggleSidebar()
    }
    #endif
}
