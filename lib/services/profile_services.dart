import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late final CollectionReference _usersRef =
  _firestore.collection('users');

  // Fetch
  /// Fetch a single user profile by ID
  Future<UserModel?> fetchUserProfile(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  Future<List<UserModel>> fetchUserProfilesByIds(Iterable<String> userIds) async {
    final uniqueIds = userIds.toSet().toList();
    if (uniqueIds.isEmpty) return [];

    final futures = uniqueIds.map((id) => _usersRef.doc(id).get());
    final snapshots = await Future.wait(futures);

    return snapshots
        .where((doc) => doc.exists)
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
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

  Future<void> incrementPostCount(String userId, {int amount = 1}) async {
    await _usersRef.doc(userId).set({
      'postCount': FieldValue.increment(amount),
      'contributionScore': FieldValue.increment(amount * 3),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _recalculateSuperUserStatus(userId);
  }

  Future<void> decrementPostCount(String userId, {int amount = 1}) async {
    await _usersRef.doc(userId).set({
      'postCount': FieldValue.increment(-amount),
      'contributionScore': FieldValue.increment(-(amount * 3)),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _recalculateSuperUserStatus(userId);
  }

  Future<void> incrementReviewCount(String userId, {int amount = 1}) async {
    await _usersRef.doc(userId).set({
      'reviewCount': FieldValue.increment(amount),
      'contributionScore': FieldValue.increment(amount * 2),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _recalculateSuperUserStatus(userId);
  }

  Future<void> decrementReviewCount(String userId, {int amount = 1}) async {
    await _usersRef.doc(userId).set({
      'reviewCount': FieldValue.increment(-amount),
      'contributionScore': FieldValue.increment(-(amount * 2)),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _recalculateSuperUserStatus(userId);
  }

  Future<void> incrementHelpfulActivity(String userId, {int amount = 1}) async {
    await _usersRef.doc(userId).set({
      'helpfulActivityCount': FieldValue.increment(amount),
      'contributionScore': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _recalculateSuperUserStatus(userId);
  }

  Future<void> decrementHelpfulActivity(String userId, {int amount = 1}) async {
    await _usersRef.doc(userId).set({
      'helpfulActivityCount': FieldValue.increment(-amount),
      'contributionScore': FieldValue.increment(-amount),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _recalculateSuperUserStatus(userId);
  }

  Future<void> markSuperUser(String userId, {required bool isSuperUser}) async {
    await _usersRef.doc(userId).set({
      'isSuperUser': isSuperUser,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _recalculateSuperUserStatus(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    final postCount = (data['postCount'] ?? 0) as int;
    final reviewCount = (data['reviewCount'] ?? 0) as int;
    final helpfulActivityCount = (data['helpfulActivityCount'] ?? 0) as int;
    final contributionScore = (data['contributionScore'] ?? 0) as int;

    final qualifies = contributionScore >= 20 ||
        (postCount >= 5 && reviewCount >= 5) ||
        (postCount >= 3 && helpfulActivityCount >= 3);

    await markSuperUser(userId, isSuperUser: qualifies);
  }

  /// Update profile photo from a URL (e.g. Cloudinary)
  Future<void> updateProfilePhotoUrl(String userId, String url) async {
    await _usersRef.doc(userId).update({'photoUrl': url});
  }

  /// update cover photo
  Future<void> updateCoverPhotoUrl(String userId, String url) async {
    await _usersRef.doc(userId).update({'coverImageUrl': url});
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
      if (email != null) 'email': email.trim(),
      if (profileDescription != null)
        'profileDescription': profileDescription.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
    };

    if (updates.isEmpty) return;
    await _usersRef.doc(userId).set(updates, SetOptions(merge: true));
  }

  // Delete cover image URL
  Future<void> deleteCoverImageUrl(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'coverImageUrl': FieldValue.delete(),
    });
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