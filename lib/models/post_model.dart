import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String name;
  final String? placeId;
  final String location ;
  final List<String> imageUrls;   // multiple images
  final String description;
  final DateTime postDate;
  final double rating;            // separate from reviews
  final int reviewCount;
  final List<String> tags;

  PostModel({
    required this.id,
    required this.userId,
    required this.name,
    this.placeId,
    required this.location,
    required this.imageUrls,
    required this.description,
    required this.postDate,
    required this.rating,
    required this.reviewCount,
    this.tags = const [], //  NEW (defaults to empty so old posts are safe)
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      placeId: map['placeId'] as String?,
      location: map['location'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '',
      postDate: (map['postDate'] as Timestamp).toDate(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      if (placeId != null) 'placeId': placeId,
      'location': location ,
      'imageUrls': imageUrls,
      'description': description,
      'postDate': postDate,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags
    };
  }
}