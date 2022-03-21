//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/21.
//

import Foundation
import Firebase

// 📝 ref:
// https://techblog.sgr-ksmt.dev/2019/09/28/180821/

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en-US")
    f.dateFormat = "yyyyMMddHHmmss"
    return f
}()

enum FirebaseTestHelper {
    static func setupFirebaseApp() {
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(googleAppID: "1:123:ios:123abc", gcmSenderID: "sender_id")
            options.projectID = "test-" + dateFormatter.string(from: Date())
            FirebaseApp.configure(options: options)
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
            print("FirebaseApp has been configured")
        }
    }

    static func deleteFirebaseApp() {
        guard let app = FirebaseApp.app() else {
            return
        }
        app.delete { _ in print("FirebaseApp has been deleted") }
    }
}
