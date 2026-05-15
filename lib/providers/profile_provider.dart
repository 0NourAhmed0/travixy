import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/profile_services.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get username => _user?.username;
  String? get profileDescription => _user?.profileDescription;
  String? get photoUrl => _user?.photoUrl;
  String? get coverImageUrl => _user?.coverImageUrl;

  // fetch user profile
  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _profileService.fetchUserProfile(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // update email and description
  Future<void> updateProfile({
    required String userId,
    String? email,
    String? profileDescription,
    String? userName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateProfile(
        userId: userId,
        email: email,
        profileDescription: profileDescription,
        userName: userName,
        photoUrl: photoUrl,
      );

      await fetchUserProfile(userId); // refresh
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // update profile photo
  Future<void> updateProfilePhoto(String userId, String url) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateProfilePhotoUrl(userId, url);
      await fetchUserProfile(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateCoverPhotoUrl(String userId, String url) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateCoverPhotoUrl(userId, url);
      await fetchUserProfile(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDescription(String userId, String description) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileService.updateProfileDescription(userId, description);
      await fetchUserProfile(userId); // refresh
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}