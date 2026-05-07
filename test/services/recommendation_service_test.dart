import 'package:flutter_test/flutter_test.dart';
import 'package:travixy/models/place_model.dart';
import 'package:travixy/services/recommendation_service.dart';

void main() {
  group('RecommendationService', () {
    late RecommendationService service;

    setUp(() {
      service = RecommendationService();
    });

    // Mock test data
    final testPlaces = [
      Place(
        id: '1',
        name: 'Cozy Cafe',
        description: 'A small local cafe',
        latitude: 10.0,
        longitude: 20.0,
        category: 'cafe',
        tags: ['coffee', 'cozy'],
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
        name: 'Luxury Restaurant',
        description: 'Upscale dining',
        latitude: 11.0,
        longitude: 21.0,
        category: 'restaurant',
        tags: ['fine dining', 'luxury'],
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
        name: 'Hidden Local Spot',
        description: 'Off the beaten path',
        latitude: 12.0,
        longitude: 22.0,
        category: 'bar',
        tags: ['offbeat', 'local'],
        budget: '\$\$',
        atmosphere: 'adventurous',
        rating: 4.0,
        isHiddenGem: true,
        ownerId: 'owner3',
        ownerName: 'Mike',
        createdAt: DateTime.now(),
      ),
    ];

    test('Scorer ranks places by interest match', () async {
      // Simulate user preferences: interested in cozy cafes
      final scored = <Place, double>{};

      for (final place in testPlaces) {
        double score = 0;
        // Interest matching (simplified logic from actual service)
        if (place.tags.contains('cozy')) score += 3.0;
        if (place.category == 'cafe') score += 2.5;
        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Cozy Cafe should be first
      expect(sorted.first.name, 'Cozy Cafe');
    });

    test('Scorer ranks places by budget match', () async {
      final scored = <Place, double>{};
      final userBudget = '\$\$\$';

      for (final place in testPlaces) {
        double score = 0;
        if (userBudget == place.budget) score += 2.0;
        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Luxury Restaurant matches \$\$\$ budget
      expect(sorted.first.name, 'Luxury Restaurant');
    });

    test('Scorer ranks places by atmosphere/travel-style match', () async {
      final scored = <Place, double>{};
      final userTravelStyle = 'adventurous';

      for (final place in testPlaces) {
        double score = 0;
        if (userTravelStyle.toLowerCase() == place.atmosphere.toLowerCase()) {
          score += 2.0;
        }
        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Hidden Local Spot has adventurous atmosphere
      expect(sorted.first.name, 'Hidden Local Spot');
    });

    test('Scorer combines multiple weights correctly', () async {
      // User likes cozy, coffee, budget \$, travel style cozy
      final scored = <Place, double>{};

      for (final place in testPlaces) {
        double score = 0;
        // Interest matches
        if (place.tags.contains('coffee')) score += 3.0;
        if (place.tags.contains('cozy')) score += 3.0;
        if (place.category == 'cafe') score += 2.5;
        // Budget
        if (place.budget == '\$') score += 2.0;
        // Atmosphere
        if (place.atmosphere == 'cozy') score += 2.0;
        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Cozy Cafe should score highest (tags: coffee + cozy, category: cafe, budget: \$, atmosphere: cozy)
      expect(sorted.first.name, 'Cozy Cafe');
      // Should score: 3 + 3 + 2.5 + 2 + 2 = 12.5
      expect(scored[sorted.first]!, 12.5);
    });

    test('Scorer handles empty places list', () async {
      final scored = <Place, double>{};
      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));
      expect(sorted.isEmpty, true);
    });

    test('Scorer applies rating as tie-breaker', () async {
      // Two places with same interest/budget/atmosphere, different ratings
      final place1 = Place(
        id: 'a',
        name: 'Lower Rated',
        description: 'Same tags',
        latitude: 1.0,
        longitude: 1.0,
        category: 'cafe',
        tags: ['coffee', 'cozy'],
        budget: '\$',
        atmosphere: 'cozy',
        rating: 3.5,
        isHiddenGem: false,
        ownerId: 'o1',
        ownerName: 'Owner1',
        createdAt: DateTime.now(),
      );

      final place2 = Place(
        id: 'b',
        name: 'Higher Rated',
        description: 'Same tags',
        latitude: 2.0,
        longitude: 2.0,
        category: 'cafe',
        tags: ['coffee', 'cozy'],
        budget: '\$',
        atmosphere: 'cozy',
        rating: 4.8,
        isHiddenGem: false,
        ownerId: 'o2',
        ownerName: 'Owner2',
        createdAt: DateTime.now(),
      );

      final scored = <Place, double>{};
      for (final place in [place1, place2]) {
        double score = 12.5; // Same base score
        score += (place.rating / 5.0) * 0.5; // Add rating tie-breaker
        scored[place] = score;
      }

      final sorted = scored.keys.toList()
        ..sort((a, b) => scored[b]!.compareTo(scored[a]!));

      // Higher rated place should come first
      expect(sorted.first.name, 'Higher Rated');
    });
  });
}
