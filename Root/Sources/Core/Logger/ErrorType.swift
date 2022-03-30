//
//  File.swift
//
//
//  Created by Yusuke Hosonuma on 2022/03/30.
//

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
