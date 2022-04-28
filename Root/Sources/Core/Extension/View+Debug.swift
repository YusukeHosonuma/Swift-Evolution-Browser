//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/04/28.
//

import SwiftUI

#if DEBUG
import SwiftUISimulator
#endif

public extension View {
    func debugFilename(_ file: StaticString = #file) -> some View {
        #if DEBUG
        simulatorDebugFilename(file)
        #else
        self
        #endif
    }
}
