import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String name;
  final List<String> imageUrls;   // multiple images
  final String description;
  final DateTime postDate;
  final List<String> reviews;     // text only
  final double rating;            // separate from reviews
  final int reviewCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.imageUrls,
    required this.description,
    required this.postDate,
    required this.reviews,
    required this.rating,
    required this.reviewCount,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '',
      postDate: (map['postDate'] as Timestamp).toDate(),
      reviews: List<String>.from(map['reviews'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'imageUrls': imageUrls,
      'description': description,
      'postDate': postDate,
      'reviews': reviews,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}