import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/post_tags.dart';
import '../models/place_model.dart';

class RecommendationService {
  RecommendationService();

  /// Rank places using a simple deterministic scorer based on stored user preferences.
  /// Returns up to [limit] places sorted by score (highest first).
  Future<List<Place>> rankPlacesForUser({
    required String uid,
    required List<Place> places,
    int limit = 10,
  }) async {
    if (uid.isEmpty) return [];

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    final prefs = data['preferences'] as Map<String, dynamic>? ?? {};

    final List<String> interests = List<String>.from(prefs['interests'] ?? []);
    final String budget = prefs['budget'] ?? '';
    final String travelStyle = prefs['travelStyle'] ?? '';

    final scored = <Place, double>{};
    final expandedInterestTags = interests
        .expand(PostTags.expandPreferenceToTagLabels)
        .map((tag) => tag.toLowerCase())
        .toSet();

    for (final place in places) {
      double score = 0;
      final placeTags = place.tags.map((t) => t.toLowerCase()).toSet();

      // Interest/tag matching (high weight)
      for (final interestTag in expandedInterestTags) {
        if (placeTags.contains(interestTag)) {
          score += 3.0;
        }
        if (place.category.toLowerCase() == interestTag) {
          score += 2.5;
        }
      }

      // Budget match (medium)
      if (budget.isNotEmpty && budget == place.budget) score += 2.0;

      // Travel style -> atmosphere (medium)
      if (travelStyle.isNotEmpty && travelStyle.toLowerCase() == place.atmosphere.toLowerCase()) score += 2.0;

      // Hidden gem boost if user likes offbeat
      final offbeatLikes = interests.map((s) => s.toLowerCase()).contains('hidden gems') || interests.map((s) => s.toLowerCase()).contains('offbeat');
      if (place.isHiddenGem && offbeatLikes) score += 1.5;

      // Rating as tie-breaker
      score += (place.rating / 5.0) * 0.5;

      scored[place] = score;
    }

    final sorted = scored.keys.toList()
      ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

    return sorted.take(limit).toList();
  }
}
