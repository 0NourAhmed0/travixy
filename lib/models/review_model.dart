import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? review;   // optional
  final int rating;    //  mandatory
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.review,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    final createdAtValue = map['createdAt'];
    return ReviewModel(
      id: id,
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      review: map['review'] as String?,
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'review': review,   //  will store null if not provided
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}