import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    if (Firebase.apps.isNotEmpty) {
      _authStateSubscription = _authService.authStateChanges.listen(_handleAuthStateChanged);
    }
  }

  final AuthService _authService;
  StreamSubscription<User?>? _authStateSubscription;

  User? _currentUser;
  String _token = '';
  String _userId = '';
  String _userEmail = '';
  String _username = '';
  bool _authenticated = false;
  bool _isGuestMode = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _lastError;

  // Getters
  bool get isAuthenticated {
    return _authenticated && token.isNotEmpty;
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  String get token => _token;

  String get userId => _userId;
  String get userEmail => _userEmail;
  String get username => _username;
  User? get currentUser => _currentUser;

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  // Sign Up
  Future<String> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      _setLoading(true);
      _lastError = null;
      final credential = await _authService.signup(email: email, password: password);
      if (credential.user != null) {
        await _authService.saveUserProfile(
          user: credential.user!,
          firstName: firstName,
          lastName: lastName,
          authProvider: 'password',
        );
      }
      await _updateSession(credential.user);
      return 'success';
    } on FirebaseAuthException catch (err) {
      _lastError = err.code;
      return err.code;
    } catch (err) {
      _lastError = err.toString();
      return err.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Sign In
  Future<String> signin({required String email, required String password}) async {
    try {
      _setLoading(true);
      _lastError = null;
      final credential = await _authService.signin(email: email, password: password);
      await _updateSession(credential.user);
      return 'success';
    } on FirebaseAuthException catch (err) {
      _lastError = err.code;
      return err.code;
    } catch (err) {
      _lastError = err.toString();
      return err.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      _setLoading(true);
      _lastError = null;
      final credential = await _authService.signInWithGoogle();
      if (credential.user != null) {
        await _authService.upsertGoogleUserProfile(credential.user!);
      }
      await _updateSession(credential.user);
      return 'success';
    } on FirebaseAuthException catch (err) {
      _lastError = err.code;
      return err.code;
    } catch (err) {
      _lastError = err.toString();
      return err.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<String> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _lastError = null;
      await _authService.resetPassword(email: email);
      return 'success';
    } on FirebaseAuthException catch (err) {
      _lastError = err.code;
      return err.code;
    } catch (err) {
      _lastError = err.toString();
      return err.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _isGuestMode = false;
    if (Firebase.apps.isNotEmpty) {
      await _authService.logout();
    }
    _authenticated = false;
    _token = '';
    _userId = '';
    _userEmail = '';
    _username = '';
    _currentUser = null;
    _lastError = null;
    notifyListeners();
  }

  Future<void> enterGuestMode() async {
    _isGuestMode = true;
    if (Firebase.apps.isNotEmpty) {
      await _authService.logout();
    }
    _authenticated = false;
    _token = '';
    _userId = '';
    _userEmail = '';
    _username = '';
    _currentUser = null;
    _lastError = null;
    notifyListeners();
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (_isGuestMode) {
      _isInitialized = true;
      return;
    }

    _currentUser = user;

    if (user == null) {
      _authenticated = false;
      _token = '';
      _userId = '';
      _userEmail = '';
      _username = '';
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _authenticated = true;
    _isGuestMode = false;
    _userId = user.uid;
    _userEmail = user.email ?? '';
    _token = (await user.getIdToken()) ?? '';
    await _loadUsername(user.uid);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _updateSession(User? user) async {
    if (user == null) {
      return;
    }

    _currentUser = user;
    _authenticated = true;
    _isGuestMode = false;
    _userId = user.uid;
    _userEmail = user.email ?? '';
    _token = (await user.getIdToken()) ?? '';
    await _loadUsername(user.uid);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadUsername(String uid) async {
    try {
      if (Firebase.apps.isEmpty) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      _username = doc.data()?['username'] ?? '';
    } catch (e) {
      _username = '';
    }
  }

  Future<String> updateUsername(String newUsername) async {
    try {
      _setLoading(true);
      _lastError = null;
      await _authService.updateUsername(uid: _userId, newUsername: newUsername);
      _username = newUsername;
      notifyListeners();
      return 'success';
    } on FirebaseException catch (err) {
      _lastError = err.code;
      return err.code;
    } catch (err) {
      _lastError = err.toString();
      return err.toString();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  bool get isGuestMode => _isGuestMode;

}