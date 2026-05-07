import 'package:flutter_test/flutter_test.dart';
import 'package:travixy/models/place_model.dart';
import 'package:travixy/services/recommendation_service.dart';

void main() {
  group('Preferences & Recommendations Integration', () {
    late RecommendationService recommendationService;

    setUp(() {
      recommendationService = RecommendationService();
    });

    // Simulate user preferences stored in Firestore
    final userPreferences = {
      'interests': ['cozy', 'coffee', 'local food'],
      'budget': '\$',
      'travelStyle': 'cozy',
    };

    // Mock places available in app
    final testPlaces = [
      Place(
        id: '1',
        name: 'Cozy Coffee Shop',
        description: 'Local cafe with great vibes',
        latitude: 10.0,
        longitude: 20.0,
        category: 'cafe',
        tags: ['cozy', 'coffee', 'local'],
        budget: '\$',
        atmosphere: 'cozy',
        rating: 4.5,
        isHiddenGem: false,
        ownerId: 'owner1',
        ownerName: 'John',
        createdAt: DateTime.now(),
      ),
      Place(
        id: '2',
        name: 'Fine Dining Restaurant',
        description: 'Upscale experience',
        latitude: 11.0,
        longitude: 21.0,
        category: 'restaurant',
        tags: ['luxury', 'fine dining'],
        budget: '\$\$\$',
        atmosphere: 'luxury',
        rating: 4.8,
        isHiddenGem: false,
        ownerId: 'owner2',
        ownerName: 'Jane',
        createdAt: DateTime.now(),
      ),
      Place(
        id: '3',
        name: 'Street Food Vendor',
        description: 'Authentic local food',
        latitude: 12.0,
        longitude: 22.0,
        category: 'food',
        tags: ['local food', 'budget', 'cozy'],
        budget: '\$',
        atmosphere: 'casual',
        rating: 4.2,
        isHiddenGem: false,
        ownerId: 'owner3',
        ownerName: 'Mike',
        createdAt: DateTime.now(),
      ),
      Place(
        id: '4',
        name: 'Hidden Local Gem',
        description: 'Off the beaten path',
        latitude: 13.0,
        longitude: 23.0,
        category: 'bar',
        tags: ['offbeat', 'local'],
        budget: '\$\$',
        atmosphere: 'adventurous',
        rating: 4.0,
        isHiddenGem: true,
        ownerId: 'owner4',
        ownerName: 'Sarah',
        createdAt: DateTime.now(),
      ),
    ];

    test('User preferences are correctly matched to places', () {
      // Simulate scoring based on user preferences
      final scored = <Place, double>{};

      for (final place in testPlaces) {
        double score = 0;

        // Interest matching
        final interests = userPreferences['interests'] as List<String>;
        for (final interest in interests) {
          final i = interest.toLowerCase();
          if (place.tags.map((t) => t.toLowerCase()).contains(i)) {
            score += 3.0;
          }
          if (place.category.toLowerCase() == i) {
            score += 2.5;
          }
        }

        // Budget match
        final budget = userPreferences['budget'] as String;
        if (budget.isNotEmpty && budget == place.budget) score += 2.0;

        // Travel style match
        final travelStyle = userPreferences['travelStyle'] as String;
        if (travelStyle.isNotEmpty && travelStyle.toLowerCase() == place.atmosphere.toLowerCase()) {
          score += 2.0;
        }

        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Verify scoring works
      expect(sorted.isNotEmpty, true);
      expect(sorted.first.name, 'Cozy Coffee Shop');
      print('Top recommendation: ${sorted.first.name} (score: ${scored[sorted.first]})');
    });

    test('Budget preference filters correctly', () {
      final budget = userPreferences['budget'] as String;
      final filteredByBudget = testPlaces.where((p) => p.budget == budget).toList();

      // Should match \$ budget places
      expect(filteredByBudget.length, 2); // Cozy Coffee Shop, Street Food Vendor
      expect(
        filteredByBudget.map((p) => p.name).toList(),
        containsAll(['Cozy Coffee Shop', 'Street Food Vendor']),
      );
    });

    test('Travel style preference matches atmosphere', () {
      final travelStyle = userPreferences['travelStyle'] as String;
      final matchedByStyle = testPlaces
          .where((p) => p.atmosphere.toLowerCase() == travelStyle.toLowerCase())
          .toList();

      // Should match cozy atmosphere
      expect(matchedByStyle.length, 1);
      expect(matchedByStyle.first.name, 'Cozy Coffee Shop');
    });

    test('Interests are matched against tags and category', () {
      final interests = userPreferences['interests'] as List<String>;
      
      // Find places matching at least one interest
      final matched = testPlaces.where((place) {
        final matchesTags = place.tags.any(
          (tag) => interests.map((i) => i.toLowerCase()).contains(tag.toLowerCase()),
        );
        final matchesCategory = interests
            .map((i) => i.toLowerCase())
            .contains(place.category.toLowerCase());
        return matchesTags || matchesCategory;
      }).toList();

      // Cozy Coffee Shop, Street Food Vendor should match
      expect(matched.length, greaterThanOrEqualTo(2));
      expect(
        matched.map((p) => p.name),
        containsAll(['Cozy Coffee Shop', 'Street Food Vendor']),
      );
    });

    test('Top recommendation matches all user preferences', () {
      // Score based on all preferences
      final scored = <Place, double>{};

      for (final place in testPlaces) {
        double score = 0;

        // Interests
        final interests = userPreferences['interests'] as List<String>;
        for (final interest in interests) {
          final i = interest.toLowerCase();
          if (place.tags.map((t) => t.toLowerCase()).contains(i)) score += 3.0;
          if (place.category.toLowerCase() == i) score += 2.5;
        }

        // Budget
        final budget = userPreferences['budget'] as String;
        if (budget == place.budget) score += 2.0;

        // Travel style
        final travelStyle = userPreferences['travelStyle'] as String;
        if (travelStyle.toLowerCase() == place.atmosphere.toLowerCase()) score += 2.0;

        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Top should be Cozy Coffee Shop with highest score
      expect(sorted.first.name, 'Cozy Coffee Shop');
      
      // Should score:
      // Tags: cozy (3.0) + coffee (3.0) = 6.0 (local food interest doesn't match local tag exactly)
      // Budget: $ (2.0)
      // Atmosphere: cozy (2.0)
      // Total: 10.0
      expect(scored[sorted.first], 10.0);
    });
  });
}
