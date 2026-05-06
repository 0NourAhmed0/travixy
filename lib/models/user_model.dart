class UserModel {
  final String id;
  final String email;
  final String name;
  final String userName;
  final String? photoUrl;
  final bool isSuperUser;
  final int contributionScore;
  final DateTime createdAt;
  final String profileDescription;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.userName,
    this.photoUrl,
    this.isSuperUser = false,
    this.contributionScore = 0,
    required this.createdAt,
    this.profileDescription = 'add Description'
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userName': userName,
      'photoUrl': photoUrl,
      'isSuperUser': isSuperUser,
      'contributionScore': contributionScore,
      'createdAt': createdAt.toIso8601String(),
      'profileDescription': profileDescription
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        email: json['email'],
        name: json['name'],
        userName: json['userName'],
        photoUrl: json['photoUrl'],
      isSuperUser: json['isSuperUser'] ?? false,
      contributionScore: json['contributionScore'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
        profileDescription: json['profileDescription'] ?? 'add Description'
    );
  }
}