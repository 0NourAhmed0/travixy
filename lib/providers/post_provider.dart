import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();

  List<PostModel> _posts = [];
  List<PostModel> _userPosts = [];
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // fetch all posts
  Future<void> fetchAllPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postService.fetchAllPosts();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // fetch posts by user
  Future<void> fetchUserPosts(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userPosts = await _postService.fetchUserPosts(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // create post
  Future<void> createPost(PostModel post) async {
    try {
      await _postService.createPost(post);
      await fetchAllPosts(); // refresh list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // delete post
  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      _userPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // add review
  Future<void> addReview(String postId, String review) async {
    try {
      await _postService.addReview(postId, review);
      await fetchAllPosts(); // refresh
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // update rating
  Future<void> updateRating(String postId, double rating) async {
    try {
      await _postService.updateRating(postId, rating);
      await fetchAllPosts(); // refresh
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}