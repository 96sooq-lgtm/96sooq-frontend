import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/auth/screens/login_screen.dart';
import 'package:_96_sooq/features/auth/screens/language_selection_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/help_and_support_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/settings_screen.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/features/profile/widgets/icon_and_text_widget.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class UnauthorizedProfileScreen extends StatelessWidget {
  const UnauthorizedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .center,
            children: [
              Text(
                localizations.profileTitle,
                style: isArabic
                    ? AppThemes.f16w600.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      )
                    : AppThemes.f16w600,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: SvgPicture.asset(
                        AppAssets.profilePhotoPlaceholderIc,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Login',
                        style: isArabic
                            ? AppThemes.f18w600.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              )
                            : AppThemes.f18w600,
                      ),
                      Text(
                        'Login in to your account',
                        style: isArabic
                            ? AppThemes.f12w400.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2A2F3B).withOpacity(0.8),
                              )
                            : AppThemes.f12w400.copyWith(
                                color: Color(0xFF2A2F3B).withOpacity(0.8),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              _buildAppPreferences(
                context: context,
                isArabic: isArabic,
                heading: localizations.appPreferencesHeading,
                optionName1: localizations.languageTitle,
                optionName2: localizations.settingsTitle,
                iconName1: AppAssets.languageIc,
                iconName2: AppAssets.settingsIc,
                onTap1: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguageSelectionScreen(),
                    ),
                  );
                },
                onTap2: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.supportHeading,
                    style: isArabic
                        ? AppThemes.f14w600.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          )
                        : AppThemes.f14w600,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfff7f8f9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    child: IconAndTextWidget(
                      iconName: AppAssets.helpAndSupportIc,
                      title: localizations.helpSupportTitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpAndSupportScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 46),
              CustomButton(
                text: "Login",
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  if (!context.mounted) return;
                  if (result == true) {
                    context.read<ProfileBloc>().add(CheckAuthStatus());
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppPreferences({
    required BuildContext context,
    required bool isArabic,
    required String heading,
    required String optionName1,
    required String optionName2,
    required String iconName1,
    required String iconName2,
    required void Function() onTap1,
    required void Function() onTap2,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          heading,
          style: isArabic
              ? AppThemes.f14w600.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                )
              : AppThemes.f14w600,
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xfff7f8f9),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Column(
            children: [
              IconAndTextWidget(
                iconName: iconName1,
                title: optionName1,
                onTap: onTap1,
              ),
              Divider(color: AppColors.primaryColor.withOpacity(0.03)),
              IconAndTextWidget(
                iconName: iconName2,
                title: optionName2,
                onTap: onTap2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
