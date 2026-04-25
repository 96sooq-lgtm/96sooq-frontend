import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_event.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_state.dart';
import 'package:_96_sooq/features/auth/data/services/language_api_service.dart';
import 'package:_96_sooq/features/auth/widgets/language_selection_widget.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/features/root/view/screens/root_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguageApiService _languageApiService = const LanguageApiService();
  bool _isLanguageSwitching = false;
  Locale? _pendingLocale;

  Future<void> _onLanguageTap(BuildContext context, Locale locale) async {
    final languageBloc = context.read<LanguageBloc>();
    final currentLocale = languageBloc.state.locale;
    if (_isLanguageSwitching ||
        currentLocale.languageCode == locale.languageCode) {
      return;
    }

    setState(() {
      _isLanguageSwitching = true;
      _pendingLocale = locale;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    await _languageApiService.updateLanguage(language: locale.languageCode);
    languageBloc.add(ChangeLanguage(locale));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<LanguageBloc, LanguageState>(
          listener: (context, state) {
            if (_isLanguageSwitching &&
                _pendingLocale?.languageCode == state.locale.languageCode) {
              setState(() {
                _isLanguageSwitching = false;
                _pendingLocale = null;
              });
            }
          },
          builder: (context, state) {
            final isArabic = state.locale.languageCode == 'ar';
            final isEnglish = state.locale.languageCode == 'en';

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                /// 🔹 Image section
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60.0,
                        vertical: 40,
                      ),
                      child: Image.asset(AppAssets.logoHq, fit: BoxFit.contain),
                    ),
                  ),
                ),

                /// 🔹 Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isLanguageSwitching
                        ? const _LanguageSelectionShimmer()
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Column(
                              key: ValueKey(state.locale.languageCode),
                              children: [
                                Text(
                                  localizations.selectLanguageLabel,
                                  style: isArabic
                                      ? AppThemes.f24w500.copyWith(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        )
                                      : AppThemes.f24w500.copyWith(
                                          color: Colors.white,
                                        ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  localizations.chooseyourpreferredlanguage,
                                  style: isArabic
                                      ? AppThemes.f14w400.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFFE2E8F0),
                                        )
                                      : AppThemes.f14w400.copyWith(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                LanguageSelectionWidget(
                                  language: 'English',
                                  isSelected: isEnglish,
                                  assetPath: AppAssets.usFlagPng,
                                  onTap: () => _onLanguageTap(
                                    context,
                                    const Locale('en'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                LanguageSelectionWidget(
                                  language: 'Arabic\nالعربية',
                                  isSelected: isArabic,
                                  assetPath: AppAssets.omanFlagSPng,
                                  onTap: () => _onLanguageTap(
                                    context,
                                    const Locale('ar'),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                CustomButton(
                                  text: localizations.continueText,
                                  color: Colors.white,
                                  textStyle: isArabic
                                      ? AppThemes.f18w600.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        )
                                      : AppThemes.f16w600.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  onPressed: () {
                                    _markLanguageSelectedAndContinue(context);
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _markLanguageSelectedAndContinue(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_selected_language', true);

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => RootScreen()),
    );
  }
}

class _LanguageSelectionShimmer extends StatelessWidget {
  const _LanguageSelectionShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6E6E6),
      highlightColor: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          Container(
            height: 30,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 18,
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 34),
          _shimmerLanguageCard(),
          const SizedBox(height: 12),
          _shimmerLanguageCard(),
          const SizedBox(height: 40),
          Container(
            height: 58,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _shimmerLanguageCard() {
    return Container(
      width: double.infinity,
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
    );
  }
}
