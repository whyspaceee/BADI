import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //class to handle authentication
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  //creates a stream of the User class, update everytime an auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future signUp({required String email, required String password}) async {
    String errorMessage;
    String errorcode;
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorcode = e.code;
      switch (e.code) {
        case "email-already-in-use":
          errorMessage = "Invalid email address.";
          break;
        case "invalid-email":
          errorMessage = "Invalid email address.";
          break;
        case "weak-password":
          errorMessage = "Your password is not strong enough";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      if (errorMessage != null) {
        throw FirebaseAuthException(code: errorcode, message: errorMessage);
      }
    }
  }

  Future signIn({required String email, required String password}) async {
    String errorMessage;
    String errorcode;
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorcode = e.code;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Invalid email address.";
          break;
        case "wrong-password":
          errorMessage = "Incorrect username or password.";
          break;
        case "user-not-found":
          errorMessage = "User with this email doesn't exist.";
          break;
        case "user-disabled":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      if (errorMessage != null) {
        throw FirebaseAuthException(code: errorcode, message: errorMessage);
      }
    }
  }
}
