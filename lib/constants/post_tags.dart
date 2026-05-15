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
}