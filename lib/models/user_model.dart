class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isSuperUser;
  final int contributionScore;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.isSuperUser = false,
    this.contributionScore = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'isSuperUser': isSuperUser,
      'contributionScore': contributionScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      isSuperUser: json['isSuperUser'] ?? false,
      contributionScore: json['contributionScore'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}