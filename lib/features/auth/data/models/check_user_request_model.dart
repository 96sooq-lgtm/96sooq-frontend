class CheckUserRequest {
  final String provider;
  final String providerId;
  final String email;

  const CheckUserRequest({
    required this.provider,
    required this.providerId,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider': provider,
      'provider_id': providerId,
      'email': email,
    };
  }
}
