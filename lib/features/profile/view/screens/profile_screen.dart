import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_state.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/features/profile/view/screens/authorized_profile_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/unauthorized_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          // Auth completed — re-check so profile screen updates
          context.read<ProfileBloc>().add(CheckAuthStatus());
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ProfileAuthorized) {
            return AuthorizedProfileScreen(user: state.user);
          }

          return const UnauthorizedProfileScreen();
        },
      ),
    );
  }
}
