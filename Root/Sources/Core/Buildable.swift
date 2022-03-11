//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/02/25.
//

import Foundation
import SwiftUI

public protocol Buildable {
    associatedtype ViewType: View
    associatedtype Input
    func makeView(_ input: Input) -> ViewType
}
