@testable import Auth
import XCTest
import FirebaseAuth
import Firebase

// đ Emulator ăăăŸăćăăăȘăăŁăăźă§æ°ăćăăăćéăăă

//final class UserDocumentTests: XCTestCase {
//    override func setUp() {
//        super.setUp()
//        FirebaseTestHelper.setupFirebaseApp()
//    }
//
//    override func tearDown() {
//        super.tearDown()
//        FirebaseTestHelper.deleteFirebaseApp()
//    }
//
//    func test_createNewUser() async throws {
//        FirebaseAuth.Auth.auth().useEmulator(withHost:"localhost", port: 9099)
//
//        let auth = FirebaseAuth.Auth.auth()
//        do {
//            let r = try await auth.createUser(withEmail: "x123@example.com", password: "password")
//        } catch {
//            print(error)
//        }
//
//        let user = User(uid: "x123", name: "")
//        await UserDocument.createNewUser(user: user)
//
//        var doc = await UserDocument.get(user: user)
//        XCTAssertEqual(doc.id, user.uid)
//        XCTAssertTrue(doc.stars.isEmpty)
//
//        doc.stars = ["SE-001"]
//        await doc.update()
//
//        let updateDoc = await UserDocument.get(user: user)
//        XCTAssertTrue(updateDoc.stars.isEmpty)
//    }
//}
