import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart';

class CompleteProfileResponse {
  final bool exists;
  final String email;
  final String? accessToken;
  final String? tokenType;
  final AuthUser? user;

  const CompleteProfileResponse({
    required this.exists,
    required this.email,
    this.accessToken,
    this.tokenType,
    this.user,
  });

  factory CompleteProfileResponse.fromJson(Map<String, dynamic> json) {
    AuthUser? parsedUser;
    if (json['user'] is Map<String, dynamic>) {
      parsedUser = AuthUser.fromJson(json['user'] as Map<String, dynamic>);
    } else if (json['id'] != null || json['name'] != null) {
      // Some backends return a flat payload instead of nested "user".
      parsedUser = AuthUser(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        phoneNumber: (json['phone_number'] ?? '').toString(),
        profilePicture: (json['profile_picture'] ?? '').toString(),
      );
    }

    return CompleteProfileResponse(
      exists: json['exists'] == true || parsedUser != null,
      email: (json['email'] ?? '').toString(),
      accessToken: json['access_token']?.toString(),
      tokenType: json['token_type']?.toString(),
      user: parsedUser,
    );
  }
}
