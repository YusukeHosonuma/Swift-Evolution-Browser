//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/22.
//

#if os(iOS)
import Foundation
import UIKit

public extension UIApplication {
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
