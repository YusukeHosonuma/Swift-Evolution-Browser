//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/04/28.
//

import SwiftUI

#if DEBUG && os(iOS)
import SwiftUISimulator
#endif

public extension View {
    func debugFilename(_ file: StaticString = #file) -> some View {
        #if DEBUG && os(iOS)
        simulatorDebugFilename(file)
        #else
        self
        #endif
    }
}
