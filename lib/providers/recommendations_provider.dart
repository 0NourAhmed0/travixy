import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../services/recommendation_service.dart';

class RecommendationsProvider with ChangeNotifier {
  final RecommendationService _service = RecommendationService();

  List<Place> _recommended = [];
  List<Place> get recommended => [..._recommended];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadRecommendations({required String uid, required List<Place> places, int limit = 10}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _recommended = await _service.rankPlacesForUser(uid: uid, places: places, limit: limit);
    } catch (err) {
      _recommended = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
