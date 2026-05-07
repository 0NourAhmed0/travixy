import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // fetch all reviews by post id
  Future<void> fetchReviewsByPost(String postId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.fetchReviewsByPost(postId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // add review
  Future<void> addReview({
    required String postId,
    required String userId,
    required int rating,
    String? review,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newReview = ReviewModel(
        id: '',
        postId: postId,
        userId: userId,
        review: review,
        rating: rating,
        createdAt: DateTime.now(),
      );
      await _reviewService.addReview(newReview);
      await fetchReviewsByPost(postId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // edit review
  Future<void> editReview({
    required String reviewId,
    required String postId,
    String? review,
    int? rating,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reviewService.editReview(reviewId, postId, review: review, rating: rating);
      await fetchReviewsByPost(postId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // delete review
  Future<void> deleteReview({
    required String reviewId,
    required String postId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reviewService.deleteReview(reviewId, postId);
      await fetchReviewsByPost(postId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}