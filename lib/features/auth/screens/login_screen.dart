import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/auth/screens/create_user_screen.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/shared/global_widgets/custom_icon_button_white.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController mobileNumberController = .new();
  TextEditingController countryCodeController = .new();
  late final AnimationController _animationController;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _footerOpacity;
  late final Animation<Offset> _footerSlide;

  Future<void> _onAuthStateChanged(AuthState state) async {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      return;
    }

    if (state is AuthAuthenticated) {
      context.read<ProfileBloc>().add(CheckAuthStatus());
      if (!mounted) return;
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
      if (isCurrentRoute) {
        Navigator.pop(context, true);
      }
      return;
    }

    if (state is AuthNeedsProfileCompletion) {
      if (!mounted) return;
      final created = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CreateUserScreen(
            email: state.email,
            providerId: state.providerId,
            profilePicture: state.profilePicture,
            initialName: state.initialName,
          ),
        ),
      );
      if (!mounted) return;
      if (created == true) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void initState() {
    countryCodeController.text = '+968';
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _footerOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    _footerSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    countryCodeController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }

  bool get isArabic =>
      context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _onAuthStateChanged(state),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).padding.top,
                  color: Colors.white,
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.primaryColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisAlignment: .start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      ),
                      FadeTransition(
                        opacity: _headerOpacity,
                        child: SlideTransition(
                          position: _headerSlide,
                          child: Column(
                            children: [
                              Image.asset(AppAssets.logo),
                              const SizedBox(height: 10),
                              Text(
                                localizations.letsGetStartedText,
                                style: AppThemes.f20w600.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              // const SizedBox(height: 8),
                              // Text(
                              //   AppStrings.loginDescription,
                              //   textAlign: TextAlign.center,
                              //   style: AppThemes.f12w400.copyWith(
                              //     color: AppColors.subTextColor,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      FadeTransition(
                        opacity: _footerOpacity,
                        child: SlideTransition(
                          position: _footerSlide,
                          child: Column(
                            children: [
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: CustomIconButtonWhite(
                                      text:
                                          localizations.continueWithGoogleText,
                                      icon: AppAssets.googleIc,
                                      textStyle: isArabic
                                          ? AppThemes.f18w600.copyWith(
                                              fontWeight: FontWeight.w700,
                                            )
                                          : AppThemes.f16w600.copyWith(
                                              fontWeight: isArabic
                                                  ? FontWeight.w700
                                                  : FontWeight.w600,
                                            ),
                                      isLoading: isLoading,
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                          GoogleSignInRequested(),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'or',
                                style: AppThemes.f12w500.copyWith(
                                  color: const Color(0xFFC5C5C5),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: CustomIconButtonWhite(
                                  text: localizations.continueWithAppleText,
                                  icon: AppAssets.appleLogoSvg,
                                  textStyle: isArabic
                                      ? AppThemes.f18w600.copyWith(
                                          fontWeight: FontWeight.w700,
                                        )
                                      : AppThemes.f16w600.copyWith(
                                          fontWeight: isArabic
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Apple sign in is coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                localizations.agreeTermsConditionsText,
                                style: AppThemes.f12w500.copyWith(
                                  color: const Color(0xFFC5C5C5),
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: 40,
                end: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
