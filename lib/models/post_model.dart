// lib/models/post_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final bool isPrivate;
  final String name;
  final String? placeId;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final String? videoUrl; // ← NEW
  final String description;
  final DateTime postDate;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  PostModel({
    required this.id,
    required this.userId,
    this.isPrivate = false,
    required this.name,
    this.placeId,
    required this.location,
    this.latitude,
    this.longitude,
    required this.imageUrls,
    this.videoUrl,
    required this.description,
    required this.postDate,
    required this.rating,
    required this.reviewCount,
    this.tags = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      id: id,
      userId: map['userId'] ?? '',
      isPrivate: map['isPrivate'] ?? false,
      name: map['name'] ?? '',
      placeId: map['placeId'] as String?,
      location: map['location'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrl: map['videoUrl'] as String?, // ← NEW (null safe, old posts unaffected)
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
      'isPrivate': isPrivate,
      'name': name,
      if (placeId != null) 'placeId': placeId,
      'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'imageUrls': imageUrls,
      if (videoUrl != null) 'videoUrl': videoUrl,
      'description': description,
      'postDate': postDate,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
    };
  }
}