//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import FirebaseCrashlytics
import Foundation

public final class Logger {
    private init() {}

    public static func error(_ error: ErrorType, filePath: StaticString = #file, line: UInt = #line) {
        // 💡 It can't actually happen `nil`.
        let fileName = String(filePath).split(separator: "/").last ?? "(unknown)"

        let path = "\(fileName)@L\(line)"
        let message = "Logical Error: \(error) - \(path)"

        // 💡 Assertion error to crash when development.
        assertionFailure(message)

        Crashlytics.crashlytics().record(error: error.nsError(path: path))
    }
}
