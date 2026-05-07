import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String name;
  final String location ;
  final List<String> imageUrls;   // multiple images
  final String description;
  final DateTime postDate;
  final double rating;            // separate from reviews
  final int reviewCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.imageUrls,
    required this.description,
    required this.postDate,
    required this.rating,
    required this.reviewCount,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      description: map['description'] ?? '',
      postDate: (map['postDate'] as Timestamp).toDate(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'location': location ,
      'imageUrls': imageUrls,
      'description': description,
      'postDate': postDate,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}