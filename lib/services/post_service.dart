import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _postsRef =
  FirebaseFirestore.instance.collection('posts');

  // fetch all posts
  Future<List<PostModel>> fetchAllPosts() async {
    final snapshot = await _postsRef
        .orderBy('postDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // fetch posts by a specific user
  Future<List<PostModel>> fetchUserPosts(String userId) async {
    final snapshot = await _postsRef
        .where('userId', isEqualTo: userId)
        .orderBy('postDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // create a post
  Future<void> createPost(PostModel post) async {
    await _postsRef.add(post.toMap());
  }

  // delete a post
  Future<void> deletePost(String postId) async {
    await _postsRef.doc(postId).delete();
  }

  // add a review to a post
  Future<void> addReview(String postId, String review) async {
    await _postsRef.doc(postId).update({
      'reviews': FieldValue.arrayUnion([review]),
      'reviewCount': FieldValue.increment(1),
    });
  }

  // update rating
  Future<void> updateRating(String postId, double newRating) async {
    await _postsRef.doc(postId).update({'rating': newRating});
  }
}