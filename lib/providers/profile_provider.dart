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
  bool get isSuperUser => _user?.isSuperUser ?? false;
  int get contributionScore => _user?.contributionScore ?? 0;
  int get postCount => _user?.postCount ?? 0;
  int get reviewCount => _user?.reviewCount ?? 0;
  int get helpfulActivityCount => _user?.helpfulActivityCount ?? 0;

  // fetch user profile
  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // try {
    //   _user = await _profileService.fetchUserProfile(userId);
    //   _profileService.fetchUniquePlacesCount(userId),
    //
    // } catch (e) {
    //   _error = e.toString();
    // }

    try {
      // Run both in parallel — no extra latency
      final results = await Future.wait([
        _profileService.fetchUserProfile(userId),
        _profileService.fetchUniquePlacesCount(userId),
      ]);

      _user = results[0] as UserModel?;
      _uniquePlacesCount = results[1] as int;
      _travelerBadge = _profileService.resolveBadge(_uniquePlacesCount);
      // ⚠️ _resolveBadge is private — either make it internal or expose it:
      // Option A: make it public → resolveBadge()
      // Option B: add a resolveFromCount(int) helper in the provider
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

  //BADGE

  TravelerBadge _travelerBadge = TravelerBadge.none;
  int _uniquePlacesCount = 0;

// Add getters:
  TravelerBadge get travelerBadge => _travelerBadge;
  int get uniquePlacesCount => _uniquePlacesCount;

  Future<void> refreshBadge(String userId) async {
    _uniquePlacesCount = await _profileService.fetchUniquePlacesCount(userId);
    _travelerBadge = _profileService.resolveBadge(_uniquePlacesCount);
    notifyListeners();
  }

}