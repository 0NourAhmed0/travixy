import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/post_service.dart';
import '../services/profile_services.dart';

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  final ProfileService _profileService = ProfileService();

  List<PostModel> _posts = [];
  List<PostModel> _userPosts = [];
  PostModel ?_userPost = null  ;
  bool _isLoading = false;
  String? _error;
  final Map<String, UserModel> _authorProfiles = {};

  List<PostModel> get posts => _posts;
  PostModel? get post => _userPost ;
  List<PostModel> get userPosts => _userPosts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserModel? authorProfileFor(String userId) => _authorProfiles[userId];

  int _boostScoreFor(PostModel post) {
    final author = _authorProfiles[post.userId];
    if (author == null) {
      return 0;
    }

    var score = author.contributionScore;
    if (author.isSuperUser) {
      score += 50;
    }

    score += post.rating.round();
    score += post.reviewCount;
    return score;
  }

  Future<void> _loadAuthorProfiles(Iterable<PostModel> posts) async {
    final profiles = await _profileService.fetchUserProfilesByIds(
      posts.map((post) => post.userId),
    );

    _authorProfiles
      ..clear()
      ..addEntries(profiles.map((profile) => MapEntry(profile.id, profile)));
  }

  void _sortPostsByBoost() {
    _posts.sort((a, b) {
      final byBoost = _boostScoreFor(b).compareTo(_boostScoreFor(a));
      if (byBoost != 0) return byBoost;
      return b.postDate.compareTo(a.postDate);
    });
  }


  //-----GET----------

  // fetch all posts
  Future<void> fetchAllPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postService.fetchAllPosts();
      await _loadAuthorProfiles(_posts);
      _sortPostsByBoost();
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

  // fetch posts by user id and postid
  Future<void> fetchUserPost(String userId, String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userPost = await _postService.fetchUserPost(userId, id);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  //-----------POST-----------------

  // create post
  Future<void> createPost(PostModel post) async {
    try {
      await _postService.createPost(post);
      await fetchAllPosts(); // refresh list and global tabs ( home , search) when post added
      await fetchUserPosts(post.userId); // refreshes user profile when post created

    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  //----------DELETE ---------------
  // delete post
  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      _userPosts.removeWhere((p) => p.id == postId);
      _authorProfiles.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }


  //---------post parameters-----------

  //---------UPDATE-----------

// update rating
  Future<void> updateRating(String postId, double rating) async {
    try {
      await _postService.updateRating(postId, rating);
      await fetchAllPosts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // update post
  Future<void> updatePost(String postId, {String? name, String? location, String? description}) async {
    try {
      await _postService.updatePost(postId, name: name, location: location, description: description);
      await fetchAllPosts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  //----------DELETE----------

// delete rating
  Future<void> deleteRating(String postId) async {
    try {
      await _postService.deleteRating(postId);
      await fetchAllPosts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}