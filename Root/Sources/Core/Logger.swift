//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import FirebaseCrashlytics
import Foundation

public enum ErrorType: Int {
    case loginIsNeeded = 100

    var code: Int {
        rawValue
    }

    var domain: String {
        switch self {
        case .loginIsNeeded: return "Login is needed"
        }
    }

    var message: String {
        switch self {
        case .loginIsNeeded: return "A method that requires login was called with an not logged-in user."
        }
    }
}

public final class Logger {
    private init() {}

    public static func error(_ error: ErrorType, filePath: StaticString = #file, line: UInt = #line) {
        let fileName = String(filePath).split(separator: "/").last ?? "(unknown)" // 💡 It can't actually happen `nil`.
        let path = "\(fileName)@L\(line)"
        let message = "Logical Error: \(error) - \(path)"

        // 💡 Assertion error to crash when development.
        assertionFailure(message)

        #if os(iOS)
        Crashlytics.crashlytics().record(error: NSError(
            domain: error.domain,
            code: error.code,
            userInfo: [
                "message": error.message,
                "path": path,
            ]
        ))
        #endif
    }
}

private extension String {
    init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }
}
