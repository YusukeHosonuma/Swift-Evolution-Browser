// import * as functions from 'firebase-functions';
// import * as admin from "firebase-admin";

// admin.initializeApp()

// // Auth: on create user.
// export const onCreateUser = functions.auth.user().onCreate(async (user) => {
//   await admin.firestore()
//     .collection("users")
//     .doc(user.uid)
//     .set({
//       stars: []
//     })
//   // TODO: error handling
// });
