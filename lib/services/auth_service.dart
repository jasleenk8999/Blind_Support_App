import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    // try {
    //   UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    //   return result.user;
    // } on FirebaseAuthException catch (e) {
    //   print(e.toString());
    //   return null;
    // }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // try {
    //   UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
    //     email: email,
    //     password: password,
    //   );
    //   return result.user;
    // } on FirebaseAuthException catch (e) {
    //   print(e.toString());
    //   return null;
    // }
    return null;
  }

  Future<void> signOut() async {
    // await _firebaseAuth.signOut();
  }
}
