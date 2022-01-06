// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  static auth.User authUser;

  // LoginUser _userFromFirebaseUser(auth.User user) {
  //   if (user == null) return null;
  //   authUser = user;
  //   return LoginUser(
  //       uid: user.uid,
  //       displayName: user.displayName,
  //       phoneNumber: user.phoneNumber ?? '',
  //       email: user.email);
  // }

  // Stream<LoginUser> get fireUser {
  //   return _auth.authStateChanges().map(_userFromFirebaseUser);
  // }

  CodeSent codeSent;
  static CodeSent code;
  CodeSent get codesent => codeSent;

  //Login with phone
  Future loginWithPhone(String phone) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (auth.PhoneAuthCredential credential) {},
      verificationFailed: (auth.FirebaseAuthException e) {},
      codeSent: (String verificationId, int resendToken) async {
        code = CodeSent(verificationId, resendToken);
        print(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  //Login with phone
  Future sendOtp(String phone) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (auth.PhoneAuthCredential credential) {},
      verificationFailed: (auth.FirebaseAuthException e) {},
      codeSent: (String verificationId, int resendToken) async {
        code = CodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  //sign in with phone credentials
  Future verifyOtp(smsCode) async {
    auth.PhoneAuthCredential credential = auth.PhoneAuthProvider.credential(
        verificationId: code.id, smsCode: smsCode);
    return credential;
  }

  Future linkCredential(credential) async {
    var user = await authUser.linkWithCredential(credential);
    return user;
  }

  //sign in with phone credentials
  Future signInWithOtp(smsCode) async {
    auth.PhoneAuthCredential credential = auth.PhoneAuthProvider.credential(
        verificationId: code.id, smsCode: smsCode);
    // Sign the user in (or link) with the credential
    var user = await _auth.signInWithCredential(credential);

    return user.user;
  }

//   // Sign in with google auth
//   Future googleSignIn() async {
//     final googleUser = await _googleSignIn.signIn();
//     if (googleUser != null) if (!googleUser.email.contains('@nitk.edu.in')) {
//       _googleSignIn.signOut();
//       return null;
//     }
//     final googleAuth = await googleUser!.authentication;
//     final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     final user = await _auth.signInWithCredential(credential);
//     await createUserDoc(user);

//     return _userFromFirebaseUser(user.user);
//   }

//   // Future<auth.UserCredential> signInWithFacebook() async {
//   //   // Trigger the sign-in flow
//   //   final LoginResult result = await FacebookAuth.instance.login();

//   //   // Create a credential from the access token
//   //   final facebookAuthCredential =
//   //       auth.FacebookAuthProvider.credential(result.accessToken!.token);

//   //   // Once signed in, return the UserCredential
//   //   final user = await _auth.signInWithCredential(facebookAuthCredential);

//   //   createUserDoc(user);

//   //   return user;
//   // }

//   //Register with email and password
//   registerEmailPass(email, password) async {
//     try {
//       auth.UserCredential user = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       await createUserDoc(user);
//     } on auth.FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         print('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         print('The account already exists for that email.');
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   //Register with email and password
//   linkEmailPass(email, password) async {
//     try {
//       auth.UserCredential user = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       await createUserDoc(user);
//     } on auth.FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         print('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         print('The account already exists for that email.');
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   //Sign In with email and password
//   emailPassSignIn(email, password) async {
//     try {
//       final user = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       await createUserDoc(user);
//     } on auth.FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         print('No user found for that email.');
//       } else if (e.code == 'wrong-password') {
//         print('Wrong password provided for that user.');
//       }
//     }
//   }

//   createUserDoc(auth.UserCredential user) async {
//     print(user.user!.photoURL);
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.user!.uid)
//         .get()
//         .then((documentSnapshot) {
//       if (documentSnapshot.exists) {
//       } else {
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.user!.uid)
//             .set({
//               'id': user.user!.uid,
//               'name': user.user!.displayName,
//               'phone': user.user!.phoneNumber,
//               'email': user.user!.email,
//               'photo': user.user!.photoURL,
//               'joiningDate': FieldValue.serverTimestamp(),
//             })
//             .then((value) => print('User Added'))
//             .catchError((error) => print('Failed to add user: $error'));
//       }
//     });
//   }

//   //Sign out
//   signOut() {
//     _auth.signOut();
//   }
}

// class LoginUser {
//   String uid;
//   String? displayName;
//   String? photoUrl;
//   String? email;
//   String phoneNumber;

//   LoginUser({
//     required this.uid,
//     this.photoUrl,
//     this.displayName,
//     this.email,
//     required this.phoneNumber,
//   });
// }

class CodeSent {
  final String id;
  final token;
  CodeSent(this.id, this.token);
}
