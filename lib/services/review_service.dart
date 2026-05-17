import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import 'profile_services.dart';

class ReviewService {
  final CollectionReference _reviewsRef =
  FirebaseFirestore.instance.collection('reviews');
  final CollectionReference _postsRef =
  FirebaseFirestore.instance.collection('posts');
  final ProfileService _profileService = ProfileService();

  // get all reviews by post id
  Future<List<ReviewModel>> fetchReviewsByPost(String postId) async {
    final snapshot = await _reviewsRef
        .where('postId', isEqualTo: postId)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // add review
  Future<void> addReview(ReviewModel review) async {
    await _reviewsRef.add(review.toMap());
    await _postsRef.doc(review.postId).update({
      'reviewCount': FieldValue.increment(1),
    });
    await _profileService.incrementReviewCount(review.userId);
    if (review.rating >= 4) {
      await _profileService.incrementHelpfulActivity(review.userId);
    }
    await updatePostAverageRating(review.postId);
  }

  // edit review
  Future<void> editReview(String reviewId, String postId,String userId,String username, {String? review, int? rating}) async {
    // Fetch the review first and verify ownership
    final doc = await _reviewsRef.doc(reviewId).get();
    if (!doc.exists) throw Exception('Review not found');

    final data = doc.data() as Map<String, dynamic>;
    if (data['userId'] != userId) throw Exception('You can only edit your own reviews');

    final previousRating = (data['rating'] as num?)?.toInt() ?? 0;


    final Map<String, dynamic> updates = {};
    if (review != null) updates['review'] = review;
    if (rating != null) updates['rating'] = rating;
    await _reviewsRef.doc(reviewId).update(updates);

    if (rating != null) {
      final crossedHelpfulThreshold = previousRating >= 4;
      final isNowHelpful = rating >= 4;
      if (crossedHelpfulThreshold != isNowHelpful) {
        if (isNowHelpful) {
          await _profileService.incrementHelpfulActivity(userId);
        } else {
          await _profileService.decrementHelpfulActivity(userId);
        }
      }
    }

    await updatePostAverageRating(postId);
  }

  // delete review
  Future<void> deleteReview(String reviewId, String postId) async {
    final doc = await _reviewsRef.doc(reviewId).get();
    final data = doc.data() as Map<String, dynamic>?;
    await _reviewsRef.doc(reviewId).delete();
    await _postsRef.doc(postId).update({
      'reviewCount': FieldValue.increment(-1),
    });
    if (data != null) {
      await _profileService.decrementReviewCount(data['userId'] ?? '');
      final rating = (data['rating'] as num?)?.toInt() ?? 0;
      if (rating >= 4) {
        await _profileService.decrementHelpfulActivity(data['userId'] ?? '');
      }
    }
    await updatePostAverageRating(postId);
  }

  // compute and update average rating on post
  Future<void> updatePostAverageRating(String postId) async {
    final snapshot = await _reviewsRef
        .where('postId', isEqualTo: postId)
        .get();

    if (snapshot.docs.isEmpty) {
      await _postsRef.doc(postId).update({'rating': 0});
      return;
    }

    final ratings = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as int)
        .toList();

    final average = ratings.reduce((a, b) => a + b) / ratings.length;
    await _postsRef.doc(postId).update({'rating': average});
  }
}