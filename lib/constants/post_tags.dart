import '../models/post_tag.dart';

// Single source of truth for all predefined tags.
// Tags are grouped by category for display in the picker.
// Each tag is just a plain string — stored directly in PostModel.tags.

class PostTags {
  PostTags._();

  /// Categories
  static const String catVibe = 'Vibe';
  static const String catFood = 'Food & Drink';
  static const String catActivity = 'Activity';
  static const String catBudget = 'Budget';
  static const String catNature = 'Nature';

  /// All predefined tags
  static const List<PostTag> all = [
    // Vibe
    PostTag(label: 'Hidden gem', category: catVibe),
    PostTag(label: 'Rooftop', category: catVibe),
    PostTag(label: 'Cozy', category: catVibe),
    PostTag(label: 'Romantic', category: catVibe),
    PostTag(label: 'Lively', category: catVibe),
    PostTag(label: 'Peaceful', category: catVibe),
    PostTag(label: 'Instagrammable', category: catVibe),

    // Food & Drink
    PostTag(label: 'Coffee', category: catFood),
    PostTag(label: 'Brunch', category: catFood),
    PostTag(label: 'Street food', category: catFood),
    PostTag(label: 'Fine dining', category: catFood),
    PostTag(label: 'Desserts', category: catFood),
    PostTag(label: 'Bar', category: catFood),

    // Activity
    PostTag(label: 'Adventure', category: catActivity),
    PostTag(label: 'Shopping', category: catActivity),
    PostTag(label: 'Culture', category: catActivity),
    PostTag(label: 'Nightlife', category: catActivity),
    PostTag(label: 'Family-friendly', category: catActivity),
    PostTag(label: 'Art', category: catActivity),

    // Budget
    PostTag(label: 'Free entry', category: catBudget),
    PostTag(label: 'Budget-friendly', category: catBudget),
    PostTag(label: 'Splurge-worthy', category: catBudget),

    // Nature
    PostTag(label: 'Beach', category: catNature),
    PostTag(label: 'Mountains', category: catNature),
    PostTag(label: 'Desert', category: catNature),
    PostTag(label: 'Waterfall', category: catNature),
    PostTag(label: 'Sunset view', category: catNature),
  ];

  // Interest chips shown in onboarding. These must stay aligned with stored post tags.
  static const List<String> preferenceInterestOptions = [
    'Hidden gem',
    'Coffee',
    'Street food',
    'Adventure',
    'Culture',
    'Nightlife',
    'Beach',
    'Cozy',
  ];

  static const Map<String, List<String>> _legacyPreferenceAliases = {
    'beaches': ['Beach'],
    'beach': ['Beach'],
    'nature': ['Beach', 'Mountains', 'Waterfall', 'Sunset view'],
    'food': ['Coffee', 'Brunch', 'Street food', 'Fine dining', 'Desserts', 'Bar'],
    'hidden gems': ['Hidden gem'],
    'hidden gem': ['Hidden gem'],
    'experiences': ['Adventure', 'Culture', 'Art', 'Shopping'],
    'offbeat': ['Hidden gem'],
  };

  //helper functions

  // Returns tags grouped by category for sectioned display
  static Map<String, List<PostTag>> get byCategory {
    final map = <String, List<PostTag>>{};
    for (final tag in all) {
      map.putIfAbsent(tag.category, () => []).add(tag);
    }
    return map;
  }

  //Finds a PostTag by its label string
  static PostTag? findByLabel(String label) {
    try {
      return all.firstWhere((t) => t.label == label);
    } catch (_) {
      return null;
    }
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  // Returns a canonical tag label when a value maps to one known tag.
  // Useful when hydrating UI choices from older saved preference values.
  static String? canonicalTagLabel(String value) {
    final normalized = _normalize(value);

    for (final tag in all) {
      if (_normalize(tag.label) == normalized) {
        return tag.label;
      }
    }

    final mapped = _legacyPreferenceAliases[normalized];
    if (mapped == null || mapped.isEmpty) {
      return null;
    }
    return mapped.first;
  }

  // Expands one preference into all matching canonical post tag labels.
  // This keeps older broad preferences (like "Food") compatible.
  static Set<String> expandPreferenceToTagLabels(String preference) {
    final canonical = canonicalTagLabel(preference);
    if (canonical != null) {
      return {canonical};
    }

    final normalized = _normalize(preference);
    final mapped = _legacyPreferenceAliases[normalized];
    if (mapped != null && mapped.isNotEmpty) {
      return mapped.toSet();
    }

    return {};
  }
}