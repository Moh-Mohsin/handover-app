import 'dart:convert';

class User {
  final String name;
  final String profilePictureUrl;
  User({
    required this.name,
    required this.profilePictureUrl,
  });
  

  User copyWith({
    String? name,
    String? profilePictureUrl,
  }) {
    return User(
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(name: $name, profilePictureUrl: $profilePictureUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      other.name == name &&
      other.profilePictureUrl == profilePictureUrl;
  }

  @override
  int get hashCode => name.hashCode ^ profilePictureUrl.hashCode;
}
