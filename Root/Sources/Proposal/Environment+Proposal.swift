//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/08.
//

import Foundation
import SwiftUI

public struct ProposalStoreKey: EnvironmentKey {
    public static var defaultValue: ProposalStore? { nil }
}

extension EnvironmentValues {
    public var proposalStore: ProposalStore? {
        get {
            return self[ProposalStoreKey.self]
        }
        set {
            self[ProposalStoreKey.self] = newValue
        }
    }
}
