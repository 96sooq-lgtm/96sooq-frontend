import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart';
import 'package:_96_sooq/features/auth/screens/language_selection_screen.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_event.dart';
import 'package:_96_sooq/features/profile/bloc/store_profile/store_profile_state.dart';
import 'package:_96_sooq/features/paymets/view/screens/my_transactions_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/help_and_support_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/settings_screen.dart';
import 'package:_96_sooq/features/profile/view/screens/store_details_screen.dart';
import 'package:_96_sooq/features/profile/widgets/icon_and_text_widget.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/shared/global_widgets/app_network_image.dart';

class AuthorizedProfileScreen extends StatelessWidget {
  const AuthorizedProfileScreen({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final isArabic =
        context.watch<LanguageBloc>().state.locale.languageCode == 'ar';
    final localizations = AppLocalizations.of(context)!;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAccountDeleted) {
          context.read<ProfileBloc>().add(ProfileLogoutRequested());
          context.read<StoreProfileBloc>().add(StoreProfileCleared());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.accountDeletedSuccess),
            ),
          );
        }
      },
      child: Scaffold(
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
                        child: user.profilePicture.isEmpty
                            ? SvgPicture.asset(
                                AppAssets.profilePhotoPlaceholderIc,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : AppNetworkImage(
                                imageUrl: user.profilePicture,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                shape: BoxShape.circle,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: .start,
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          user.name.isEmpty ? 'User' : user.name,
                          style: isArabic
                              ? AppThemes.f18w600.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                )
                              : AppThemes.f18w600,
                        ),
                        Text(
                          user.email,
                          style: isArabic
                              ? AppThemes.f12w400.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(
                                    0xFF2A2F3B,
                                  ).withValues(alpha: 0.8),
                                )
                              : AppThemes.f12w400.copyWith(
                                  color: const Color(
                                    0xFF2A2F3B,
                                  ).withValues(alpha: 0.8),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                BlocBuilder<StoreProfileBloc, StoreProfileState>(
                  builder: (context, storeState) {
                    final hasStore =
                        storeState.status == StoreProfileLoadStatus.success &&
                        storeState.hasStore;
                    final accountItems = <_PreferenceItem>[
                      if (hasStore)
                        _PreferenceItem(
                          iconName: AppAssets.accountSettingsProfileIc,
                          title: localizations.myStoreTitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StoreDetailsScreen(
                                  isMyStore: true,
                                  storeId: storeState.store?.id,
                                  storeName: storeState.store?.name,
                                  storeNameAr: storeState.store?.nameAr,
                                  storeDescription: storeState.store?.description,
                                  storeLogoUrl: storeState.store?.logo,
                                  storeLocation: storeState.store?.wilayat,
                                ),
                              ),
                            );
                          },
                        ),
                      _PreferenceItem(
                        iconName: AppAssets.emailIc,
                        title: localizations.myTransactionsTitle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyTransactionsScreen(),
                            ),
                          );
                        },
                      ),
                    ];

                    return _buildAppPreferences(
                      context: context,
                      isArabic: isArabic,
                      heading: localizations.accountSettingsHeading,
                      items: accountItems,
                    );
                  },
                ),
                const SizedBox(height: 25),
                _buildAppPreferences(
                  context: context,
                  isArabic: isArabic,
                  heading: localizations.appPreferencesHeading,
                  items: [
                    _PreferenceItem(
                      iconName: AppAssets.languageIc,
                      title: localizations.languageTitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LanguageSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    _PreferenceItem(
                      iconName: AppAssets.settingsIc,
                      title: localizations.settingsTitle,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildAppPreferences(
                  context: context,
                  isArabic: isArabic,
                  heading: localizations.supportHeading,
                  items: [
                    _PreferenceItem(
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
                  ],
                ),
                const SizedBox(height: 36),
                Container(
                  height: 56,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF7F8F9),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFCA0903)),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFCA0903),
                    ),
                    title: Text(
                      localizations.logoutText,
                      style: isArabic
                          ? AppThemes.f12w400.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFCA0903),
                            )
                          : AppThemes.f12w400.copyWith(
                              color: const Color(0xFFCA0903),
                            ),
                    ),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: AppColors.white,
                            title: Text(localizations.logoutDialogTitle),
                            content: Text(localizations.logoutDialogMessage),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: Text(localizations.cancelText),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: Text(localizations.logoutText),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed != true || !context.mounted) return;

                      context.read<AuthBloc>().add(LogoutRequested());
                      context.read<ProfileBloc>().add(ProfileLogoutRequested());
                      context.read<StoreProfileBloc>().add(StoreProfileCleared());
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // ── Delete Account ──
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final isDeleting = authState is AuthLoading;
                    return Container(
                      height: 56,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFFFF0F0),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.delete_forever_outlined,
                          color: Color(0xFFCA0903),
                        ),
                        trailing: isDeleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFCA0903),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFFCA0903),
                              ),
                        title: Text(
                          isDeleting
                              ? localizations.deletingAccountText
                              : localizations.deleteAccountTitle,
                          style: isArabic
                              ? AppThemes.f12w400.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFCA0903),
                                )
                              : AppThemes.f12w400.copyWith(
                                  color: const Color(0xFFCA0903),
                                ),
                        ),
                        onTap: isDeleting
                            ? null
                            : () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      backgroundColor: AppColors.white,
                                      title: Text(
                                        localizations.deleteAccountTitle,
                                      ),
                                      content: Text(
                                        localizations.deleteAccountMessage,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            false,
                                          ),
                                          child: Text(
                                            localizations.cancelText,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                            dialogContext,
                                            true,
                                          ),
                                          child: Text(
                                            localizations.deleteAccountConfirm,
                                            style: const TextStyle(
                                              color: Color(0xFFCA0903),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed != true || !context.mounted) {
                                  return;
                                }

                                context.read<AuthBloc>().add(
                                  DeleteAccountRequested(),
                                );
                              },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppPreferences({
    required BuildContext context,
    required bool isArabic,
    required String heading,
    required List<_PreferenceItem> items,
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
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xfff7f8f9),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(
                  color: AppColors.primaryColor.withValues(alpha: 0.03),
                );
              }

              final item = items[index ~/ 2];
              return IconAndTextWidget(
                iconName: item.iconName,
                title: item.title,
                onTap: item.onTap,
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PreferenceItem {
  const _PreferenceItem({
    required this.iconName,
    required this.title,
    required this.onTap,
  });

  final String iconName;
  final String title;
  final VoidCallback onTap;
}
