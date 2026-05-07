import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> saveUserProfile({
    required User user,
    required String firstName,
    required String lastName,
    required String authProvider,
    String? username,
  }) async {
    if (Firebase.apps.isEmpty) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialized. Add your Firebase config first.',
      );
    }

    final defaultUsername = username ?? '$firstName$lastName'.replaceAll(' ', '').toLowerCase();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'firstName': firstName,
      'lastName': lastName,
      'username': defaultUsername,
      'displayName': [firstName, lastName].where((value) => value.trim().isNotEmpty).join(' '),
      'authProvider': authProvider,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> upsertGoogleUserProfile(User user) async {
    if (Firebase.apps.isEmpty) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialized. Add your Firebase config first.',
      );
    }

    final displayName = user.displayName?.trim() ?? '';
    final nameParts = displayName.split(' ').where((value) => value.isNotEmpty).toList();
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final defaultUsername = '$firstName$lastName'.replaceAll(' ', '').toLowerCase();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'firstName': firstName,
      'lastName': lastName,
      'username': defaultUsername,
      'displayName': displayName,
      'authProvider': 'google',
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Save user preferences under users/{uid}.preferences
  Future<void> saveUserPreferences({
    required String uid,
    required Map<String, dynamic> preferences,
  }) async {
    if (Firebase.apps.isEmpty) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialized. Add your Firebase config first.',
      );
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'preferences': preferences,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update user username
  Future<void> updateUsername({
    required String uid,
    required String newUsername,
  }) async {
    if (Firebase.apps.isEmpty) {
      throw FirebaseAuthException(
        code: 'firebase-not-initialized',
        message: 'Firebase is not initialized. Add your Firebase config first.',
      );
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'username': newUsername,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
