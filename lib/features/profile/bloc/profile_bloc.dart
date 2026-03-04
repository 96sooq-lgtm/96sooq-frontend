import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({AuthSessionRepository? authSessionRepository})
    : _authSessionRepository = authSessionRepository ?? AuthSessionRepository(),
      super(ProfileLoading()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  final AuthSessionRepository _authSessionRepository;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final loggedIn = await _authSessionRepository.isLoggedIn();
    final user = await _authSessionRepository.getCachedUser();

    if (loggedIn && user != null) {
      emit(ProfileAuthorized(user: user));
      return;
    }

    emit(ProfileUnauthorized());
  }

  Future<void> _onLogoutRequested(
    ProfileLogoutRequested event,
    Emitter<ProfileState> emit,
  ) async {
    await _authSessionRepository.clearSession();
    emit(ProfileUnauthorized());
  }
}
