import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String postId;
  final String userId;
  final String? review;   // optional
  final int rating;    //  mandatory
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.review,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      review: map['review'],
      rating: (map['rating'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'review': review,   //  will store null if not provided
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}