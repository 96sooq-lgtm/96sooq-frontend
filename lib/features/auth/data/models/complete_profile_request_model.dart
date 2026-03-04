class CompleteProfileRequest {
  final String provider;
  final String providerId;
  final String email;
  final String name;
  final String phoneNumber;
  final String profilePicture;

  const CompleteProfileRequest({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider': provider,
      'provider_id': providerId,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
    };
  }
}
