//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/24.
//

import Combine
import Foundation
import SwiftUI

public protocol StorageValue {
    var rawString: String { get }
    init?(rawString: String?)
}

extension String: StorageValue {
    public var rawString: String { self }
    public init?(rawString: String?) {
        guard let rawString = rawString else { return nil }
        self = rawString
    }
}

public final class UserDefaultStorage<Value: StorageValue>: ObservableObject {
    @Published public var value: Value?

    private var cancellables: Set<AnyCancellable> = []

    public init(key: String, _ defaultValue: Value?) {
        value = Value(rawString: UserDefaults.standard.string(forKey: key)) ?? defaultValue
        $value
            .dropFirst()
            .sink {
                if let value = $0 {
                    UserDefaults.standard.set(value.rawString, forKey: key)
                } else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            .store(in: &cancellables)
    }
}
