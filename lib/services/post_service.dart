import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import 'profile_services.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsRef =
  FirebaseFirestore.instance.collection('posts');
  final ProfileService _profileService = ProfileService();

  //GET
  // fetch all posts
  Future<List<PostModel>> fetchAllPosts() async {
    // Fetch first, then filter in Dart so legacy docs without isPrivate are treated as public.
    final snapshot = await _postsRef
      .orderBy('postDate', descending: true)
      .get();
    return snapshot.docs
      .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
      .where((post) => !post.isPrivate)
      .toList();
  }

  Future<Map<String, int>> fetchUserStats(String userId) async {
    print('🔍 fetchUserStats called for userId: $userId');

    final postsSnapshot = await _postsRef
        .where('userId', isEqualTo: userId)
        .get();
    print('📦 Posts found: ${postsSnapshot.docs.length}');

    final reviewsSnapshot = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();
    print('⭐ Reviews found: ${reviewsSnapshot.docs.length}');

    return {
      'postCount': postsSnapshot.docs.length,
      'reviewCount': reviewsSnapshot.docs.length,
    };
  }

  // fetch posts by a specific user
  Future<List<PostModel>> fetchUserPosts(String userId, {String? currentUserId}) async {
    final snapshot = await _postsRef
        .where('userId', isEqualTo: userId)
        .orderBy('postDate', descending: true)
        .get();

    final posts = snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // If viewing another user's profile, only show public posts.
    final isOwner = currentUserId != null && currentUserId == userId;
    if (isOwner) {
      return posts;
    }
    return posts.where((post) => !post.isPrivate).toList();
  }

  //fetch single post
  Future<PostModel?> fetchUserPost(String userId, String id, {String? currentUserId}) async {
    final doc = await _postsRef.doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;

    // verify it belongs to the user
    if (data['userId'] != userId) return null;

    // If private, only allow owner to view
    final isPrivate = data['isPrivate'] ?? false;
    if (isPrivate && currentUserId != userId) return null;

    return PostModel.fromMap(data, doc.id);
  }

  //POST
  // create a post
  Future<void> createPost(PostModel post) async {
    await _postsRef.add(post.toMap());
    await _profileService.incrementPostCount(post.userId);

    if (post.placeId != null && post.placeId!.isNotEmpty) {
      await _firestore.collection('places').doc(post.placeId).update({
        'postCount': FieldValue.increment(1),
      });
    }
  }


  //DELETE
  // delete a post
  Future<void> deletePost(String postId) async {
    final doc = await _postsRef.doc(postId).get();
    final data = doc.data() as Map<String, dynamic>?;
    await _postsRef.doc(postId).delete();
    if (data != null) {
      await _profileService.decrementPostCount(data['userId'] ?? '');
      final placeId = data['placeId'] as String?;
      if (placeId != null && placeId.isNotEmpty) {
        await _firestore.collection('places').doc(placeId).update({
          'postCount': FieldValue.increment(-1),
        });
      }
    }
  }


  // delete rating (resets to 0)
  Future<void> deleteRating(String postId) async {
    await _postsRef.doc(postId).update({'rating': 0.0});
  }

  //UPDATES

  // update rating
  Future<void> updateRating(String postId, double newRating) async {
    await _postsRef.doc(postId).update({'rating': newRating});
  }
  // update Specific post fields (only updates what you pass in)
  Future<void> updatePost(String postId, {String? name, String? location, String? description}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (location != null) updates['location'] = location;
    if (description != null) updates['description'] = description;
    if (updates.isNotEmpty) await _postsRef.doc(postId).update(updates);
  }

  // Mark all posts by a user as private in Firestore
  Future<void> makeAllUserPostsPrivate(String userId) async {
    try {
      final snapshot = await _postsRef
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'isPrivate': true});
      }
    } catch (e) {
      print('Error making all user posts private: $e');
      rethrow;
    }
  }

}