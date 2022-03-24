//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/24.
//

import Combine
import Foundation
import SwiftUI

public final class UserDefaultStorage: ObservableObject {
    @Published public var value: String?

    private var cancellables: Set<AnyCancellable> = []

    public init(_ key: String, _ defaultValue: String?) {
        value = UserDefaults.standard.string(forKey: key) ?? defaultValue
        $value
            .dropFirst()
            .removeDuplicates()
            .sink { value in
                UserDefaults.standard.set(value, forKey: key)
            }
            .store(in: &cancellables)
    }
}
