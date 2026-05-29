class UserModel {
  final String id;
  final String email;
  final String name;
  final String username;
  final String? bio;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.username,
    this.bio,
    this.avatarUrl,
    this.isPremium = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        username: json['username'] as String? ?? '',
        bio: json['bio'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        isPremium: json['is_premium'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'username': username,
        'bio': bio,
        'avatar_url': avatarUrl,
        'is_premium': isPremium,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? avatarUrl,
    bool? isPremium,
  }) =>
      UserModel(
        id: id,
        email: email,
        name: name ?? this.name,
        username: username ?? this.username,
        bio: bio ?? this.bio,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isPremium: isPremium ?? this.isPremium,
        createdAt: createdAt,
      );
}
