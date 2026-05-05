import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn();

  final GoogleSignIn _googleSignIn;

  //firebase getter , checks firebase is ready once accessed
  FirebaseAuth get _firebaseAuth {
    _ensureFirebaseReady();
    return FirebaseAuth.instance;
  }

  //uthStateChanges stream
  Stream<User?> get authStateChanges {
    if (Firebase.apps.isEmpty) {
      return const Stream<User?>.empty();
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<UserCredential> signup({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signin({
    required String email,
    required String password,
  }) async {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in was cancelled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> resetPassword({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> logout() async {
    if (Firebase.apps.isEmpty) {
      return;
    }

    await Future.wait([
      FirebaseAuth.instance.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  void _ensureFirebaseReady() {
    if (Firebase.apps.isEmpty) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialized. Add your Firebase config first.',
      );
    }
  }
}
