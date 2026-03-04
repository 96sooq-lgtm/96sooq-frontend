import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart';

abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileAuthorized extends ProfileState {
  ProfileAuthorized({required this.user});

  final AuthUser user;
}

class ProfileUnauthorized extends ProfileState {}
