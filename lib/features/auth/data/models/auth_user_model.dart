import 'dart:convert';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePicture;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      profilePicture: (json['profile_picture'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory AuthUser.fromJsonString(String source) {
    return AuthUser.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
