//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

import FirebaseCrashlytics
import Foundation

public enum ErrorType {
    case loginIsNeeded
    case logoutFailed(Error)

    var code: Int {
        switch self {
        case .loginIsNeeded: return 100
        case .logoutFailed: return 101
        }
    }

    var domain: String {
        switch self {
        case .loginIsNeeded: return "Login is needed"
        case .logoutFailed: return "Logout failed"
        }
    }

    var message: String {
        switch self {
        case .loginIsNeeded: return "A method that requires login was called with an not logged-in user."
        case .logoutFailed: return "Logout failed"
        }
    }

    func nsError(path: String) -> NSError {
        var userInfo: [String: Any] = [
            "message": message,
            "path": path,
        ]

        switch self {
        case .loginIsNeeded:
            break

        case let .logoutFailed(error):
            userInfo["cause"] = error
        }

        return .init(
            domain: domain,
            code: code,
            userInfo: userInfo
        )
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
        Crashlytics.crashlytics().record(error: error.nsError(path: path))
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
