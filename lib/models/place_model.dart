class Place {
  final String id;
  final String name;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final String category; // 'restaurant', 'hidden_gem', 'experience'
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final int postCount;
  final bool isHiddenGem;
  final String ownerId;
  final String ownerName;
  final List<String> tags;
  final String budget; // '\$', '\$\$', '\$\$\$'
  final String atmosphere; // 'cozy', 'luxury', 'casual', 'adventurous'
  final DateTime createdAt;

  Place({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.imageUrl,
    this.rating = 0,
    this.reviewCount = 0,
    this.postCount = 0,
    this.isHiddenGem = false,
    required this.ownerId,
    required this.ownerName,
    this.tags = const [],
    this.budget = '\$\$',
    this.atmosphere = 'casual',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'postCount': postCount,
      'isHiddenGem': isHiddenGem,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'tags': tags,
      'budget': budget,
      'atmosphere': atmosphere,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      category: json['category'] ?? 'experience',
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      isHiddenGem: json['isHiddenGem'] ?? false,
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      budget: json['budget'] ?? '\$\$',
      atmosphere: json['atmosphere'] ?? 'casual',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : json['createdAt'] is DateTime
              ? json['createdAt'] as DateTime
              : DateTime.now(),
    );
  }
}