//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/24.
//

import Combine
import Foundation
import SwiftUI

public final class UserDefaultStorage<Value>: ObservableObject {
    @Published public var value: Value

    private var cancellables: Set<AnyCancellable> = []

    public init(key: String, _ defaultValue: Value) where Value == String? {
        value = UserDefaults.standard.string(forKey: key) ?? defaultValue
        $value
            .dropFirst()
            .sink {
                UserDefaults.standard.set($0, forKey: key)
            }
            .store(in: &cancellables)
    }

    //
    // ☑️ Not used currently. (can remove this)
    //
    public init<R>(key: String, _ defaultValue: Value) where Value == R?, R: RawRepresentable, R.RawValue == Int {
        if UserDefaults.standard.object(forKey: key) == nil {
            value = defaultValue
        } else {
            value = R(rawValue: UserDefaults.standard.integer(forKey: key)) ?? defaultValue
        }
        $value
            .dropFirst()
            .sink {
                if let value = $0?.rawValue {
                    UserDefaults.standard.set(value, forKey: key)
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            .store(in: &cancellables)
    }
}
