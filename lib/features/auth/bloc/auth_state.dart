part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthOAuthInProgress extends AuthState {}

final class AuthNeedsProfileCompletion extends AuthState {
  AuthNeedsProfileCompletion({
    required this.email,
    required this.providerId,
    required this.profilePicture,
    required this.initialName,
  });

  final String email;
  final String providerId;
  final String profilePicture;
  final String initialName;
}

final class AuthAuthenticated extends AuthState {
  AuthAuthenticated({required this.user});

  final app_auth.AuthUser user;
}

final class AuthUnauthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  AuthFailure({required this.message});

  final String message;
}
