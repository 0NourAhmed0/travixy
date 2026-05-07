import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late final CollectionReference _usersRef =
  _firestore.collection('profiles');

  // Fetch
  /// Fetch a single user profile by ID
  Future<UserModel?> fetchUserProfile(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Stream a user profile for real-time updates
  Stream<UserModel?> streamUserProfile(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  // Edit Profile Fields

  /// Update display name
  Future<void> updateName(String userId, String newName) async {
    await _usersRef.doc(userId).update({'name': newName.trim()});
  }

  /// Update username — checks uniqueness first
  Future<void> updateUserName(String userId, String newUserName) async {
    final trimmed = newUserName.trim();

    final existing = await _usersRef
        .where('username', isEqualTo: trimmed)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty && existing.docs.first.id != userId) {
      throw Exception('Username "$trimmed" is already taken.');
    }

    await _usersRef.doc(userId).update({'username': trimmed, 'userName': trimmed});
  }

  /// Update email (Firestore record only — handle Firebase Auth separately)
  Future<void> updateEmail(String userId, String newEmail) async {
    await _usersRef.doc(userId).update({'email': newEmail.trim()});
  }

  /// Update profile description / bio
  Future<void> updateProfileDescription(
      String userId, String description) async {
    await _usersRef
        .doc(userId)
        .update({'profileDescription': description.trim()});
  }

  /// Upload a new profile picture and update photoUrl
  Future<String> updateProfilePhoto(String userId, File imageFile) async {
    final ref = _storage.ref().child('profile_photos/$userId.jpg');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final downloadUrl = await uploadTask.ref.getDownloadURL();
    await _usersRef.doc(userId).update({'photoUrl': downloadUrl});
    return downloadUrl;
  }

  /// Remove profile photo (resets to null)
  Future<void> removeProfilePhoto(String userId) async {
    try {
      await _storage.ref().child('profile_photos/$userId.jpg').delete();
    } catch (_) {
      // File may not exist — safe to ignore
    }
    await _usersRef.doc(userId).update({'photoUrl': null});
  }

  // Update

  /// Update multiple profile fields in one Firestore write.
  /// Only non-null values are written.
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? userName,
    String? email,
    String? profileDescription,
    String? photoUrl,
  }) async {
    // Username uniqueness check (if being changed)
    if (userName != null) {
      final trimmed = userName.trim();
      final existing = await _usersRef
          .where('username', isEqualTo: trimmed)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty && existing.docs.first.id != userId) {
        throw Exception('Username "$trimmed" is already taken.');
      }
    }

    final updates = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      if (userName != null) 'username': userName.trim(),
      if (userName != null) 'userName': userName.trim(),
      if (email != null) 'email': email.trim(),
      if (profileDescription != null)
        'profileDescription': profileDescription.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
    };

    if (updates.isEmpty) return;
    await _usersRef.doc(userId).update(updates);
  }

  // // Contribution Score , if posted review, added comment ?
  //
  // /// Increment contribution score by a given amount (default +1)
  // Future<void> incrementContributionScore(String userId,
  //     {int amount = 1}) async {
  //   await _usersRef.doc(userId).update({
  //     'contributionScore': FieldValue.increment(amount),
  //   });
  // }

  // Delete

  /// Delete a profile document and its stored photo
  Future<void> deleteProfile(String userId) async {
    await removeProfilePhoto(userId);
    await _usersRef.doc(userId).delete();
  }
}