import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String username;
  final String? photoUrl;
  final bool isSuperUser;
  final int contributionScore;
  final int postCount;
  final int reviewCount;
  final int helpfulActivityCount;
  final int exploredPlaces;
  final DateTime createdAt;
  final String profileDescription;
  final String? coverImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.photoUrl,
    this.isSuperUser = false,
    this.contributionScore = 0,
    this.postCount = 0,
    this.reviewCount = 0,
    this.helpfulActivityCount = 0,
    this.exploredPlaces = 0,
    required this.createdAt,
    this.profileDescription = 'add Description',
    this.coverImageUrl,
  });

  String get userName => username;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'userName': username,
      'photoUrl': photoUrl,
      'isSuperUser': isSuperUser,
      'contributionScore': contributionScore,
      'postCount': postCount,
      'reviewCount': reviewCount,
      'helpfulActivityCount': helpfulActivityCount,
      'exploredPlaces': exploredPlaces,
      'createdAt': createdAt.toIso8601String(),
      'profileDescription': profileDescription ,
      'coverImageUrl': coverImageUrl,
    };
  }

  // factory UserModel.fromJson(Map<String, dynamic> json) {
  //   return UserModel(
  //       id: json['id'] ?? json['uid'] ?? '',
  //       email: json['email'],
  //       name: json['name'],
  //       username: json['username'] ?? json['userName'] ?? '',
  //       photoUrl: json['photoUrl'],
  //       isSuperUser: json['isSuperUser'] ?? false,
  //       contributionScore: json['contributionScore'] ?? 0,
  //       createdAt: DateTime.parse(json['createdAt']),
  //       profileDescription: json['profileDescription'] ?? 'add Description' ,
  //       coverImageUrl: json['coverImageUrl'],
  //   );
  // }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle name: could be 'name' or 'firstName'+'lastName'
    final name = json['name'] ??
        '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();

    // Handle createdAt safely — fallback to now if missing
    DateTime createdAt;
    try {
      final raw = json['createdAt'];
      if (raw is Timestamp) {
        createdAt = raw.toDate();
      } else if (raw is String) {
        createdAt = DateTime.parse(raw);
      } else {
        createdAt = DateTime.now();
      }
    } catch (_) {
      createdAt = DateTime.now();
    }

    return UserModel(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'] ?? '',
      name: name,
      username: json['username'] ?? json['userName'] ?? '',
      photoUrl: json['photoUrl'],
      isSuperUser: json['isSuperUser'] ?? false,
      contributionScore: json['contributionScore'] ?? 0,
      postCount: json['postCount'] ?? 0,
      reviewCount: json['reviewCount'] ?? 0,
      helpfulActivityCount: json['helpfulActivityCount'] ?? 0,
      exploredPlaces: json['exploredPlaces'] ?? 0,
      createdAt: createdAt,
      profileDescription: json['profileDescription'] ?? 'Add a description',
      coverImageUrl: json['coverImageUrl'],
    );
  }
  UserModel copyWith({
  int? exploredPlaces,
}) {
  return UserModel(
    id: id,
    email: email,
    name: name,
    username: username,
    photoUrl: photoUrl,
    isSuperUser: isSuperUser,
    contributionScore: contributionScore,
    postCount: postCount,
    reviewCount: reviewCount,
    helpfulActivityCount: helpfulActivityCount,
    exploredPlaces: exploredPlaces ?? this.exploredPlaces,
    createdAt: createdAt,
    profileDescription: profileDescription,
    coverImageUrl: coverImageUrl,
  );
}
}