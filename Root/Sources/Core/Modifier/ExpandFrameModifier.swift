//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/21.
//

import Foundation
import SwiftUI

public extension View {
    func expandFrame() -> some View {
        modifier(ExpandFrameModifier())
    }
}

public struct ExpandFrameModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
