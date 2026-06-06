part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class GoogleSignInRequested extends AuthEvent {}

final class AppleSignInRequested extends AuthEvent {}

final class AuthSessionChanged extends AuthEvent {
  AuthSessionChanged({required this.event, required this.session});

  final AuthChangeEvent event;
  final Session? session;
}

final class OAuthCheckUserRequested extends AuthEvent {
  OAuthCheckUserRequested({required this.session});

  final Session session;
}

final class CompleteProfileRequested extends AuthEvent {
  CompleteProfileRequested({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.profilePicture,
  });

  final String provider;
  final String providerId;
  final String email;
  final String name;
  final String phoneNumber;
  final String profilePicture;
}

final class LogoutRequested extends AuthEvent {}

final class DeleteAccountRequested extends AuthEvent {}

