import 'package:_96_sooq/constants/app_assets.dart';
import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_bloc.dart';
import 'package:_96_sooq/features/profile/bloc/profile_event.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96_sooq/shared/global_widgets/textFieldLabelText.dart';
import 'package:_96_sooq/shared/global_widgets/textformfield.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/constants/app_themes.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({
    super.key,
    required this.email,
    required this.providerId,
    this.profilePicture = '',
    this.initialName = '',
    this.provider = 'google',
  });

  final String email;
  final String providerId;
  final String profilePicture;
  final String initialName;
  final String provider;

  /// Whether the name/email came from Apple and should not be editable.
  bool get isApple => provider == 'apple';

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  TextEditingController mobileNumberController = .new();
  TextEditingController fullNameController = .new();
  TextEditingController emailController = .new();
  TextEditingController countryCodeController = .new();

  @override
  void initState() {
    countryCodeController.text = '+968';
    emailController.text = widget.email;
    fullNameController.text = widget.initialName;
    super.initState();
  }

  @override
  void dispose() {
    countryCodeController.dispose();
    mobileNumberController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _submitProfile() {
    FocusScope.of(context).unfocus();

    final name = fullNameController.text.trim();
    final phone = mobileNumberController.text.trim();

    // For Apple users, the name comes from the Apple credential and may be
    // empty on subsequent authorisations (Apple only shares it once). We must
    // NOT block the user from proceeding because of a missing name — Apple's
    // Guideline 4 forbids asking for info already provided by Sign in with
    // Apple.  Phone number is the only truly required user input.
    if (!widget.isApple && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFullAllRequiredFields)),
      );
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFullAllRequiredFields)),
      );
      return;
    }

    // For Apple users, if name is empty (Apple only shares it on first auth),
    // derive a fallback from the email prefix so the backend has something.
    final effectiveName = name.isNotEmpty
        ? name
        : (widget.isApple ? widget.email.split('@').first : name);

    context.read<AuthBloc>().add(
      CompleteProfileRequested(
        provider: widget.provider,
        providerId: widget.providerId,
        email: widget.email,
        name: effectiveName,
        phoneNumber: '${countryCodeController.text}$phone',
        profilePicture: widget.profilePicture,
      ),
    );
  }

  void _onAuthStateChanged(AuthState state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      return;
    }

    if (state is AuthAuthenticated) {
      context.read<ProfileBloc>().add(CheckAuthStatus());
      Navigator.pop(context, true);
    }
  }

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
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Image.asset(AppAssets.logo),
                      const SizedBox(height: 10),
                      Text(
                        widget.isApple
                            ? localizations.createAccountTitle
                            : localizations.createAccountTitle,
                        style: AppThemes.f20w600.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isApple
                            ? localizations.enterMobileNumberHint
                            : localizations.signupDescriptionText,
                        textAlign: TextAlign.center,
                        style: AppThemes.f12w400.copyWith(
                          color: AppColors.subTextColor,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(37),
                        topRight: Radius.circular(37),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: .start,
                      children: [
                        // ── Name field ──────────────────────────────────
                        // For Apple: only show if Apple actually provided a
                        // name, and it's always disabled (read-only).
                        // For Google: show as editable.
                        if (!widget.isApple || widget.initialName.isNotEmpty) ...[
                          Textfieldlabeltext(
                            text: localizations.enterFullNameHint,
                          ),
                          const SizedBox(height: 7),
                          CustomTextFormField(
                            labelText: localizations.enterFullNameHint,
                            controller: fullNameController,
                            enabled: !widget.isApple,
                          ),
                        ],

                        // ── Mobile number field ─────────────────────────
                        Textfieldlabeltext(
                          text: localizations.enterMobileNumberHint,
                        ),
                        const SizedBox(height: 7),
                        Row(
                          crossAxisAlignment: .start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppAssets.omanFlagSPng,
                                      width: 25,
                                      height: 25,
                                    ),
                                    Text(
                                      '+968',
                                      style: AppThemes.f14w500.copyWith(
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: CustomTextFormField(
                                labelText: localizations.enterMobileNumberHint,
                                controller: mobileNumberController,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),

                        // ── Email field ─────────────────────────────────
                        // For Apple: hide entirely — Apple already provided
                        // the email via the Authentication Services
                        // framework.  Showing it as a disabled field
                        // suggests we're asking for it.
                        // For Google: show as disabled read-only.
                        if (!widget.isApple) ...[
                          Textfieldlabeltext(text: localizations.email),
                          const SizedBox(height: 7),
                          CustomTextFormField(
                            labelText: '',
                            enabled: false,
                            controller: emailController,
                          ),
                        ],

                        const SizedBox(height: 20),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: localizations.getStartedText,
                              isLoading: state is AuthLoading,
                              onPressed: _submitProfile,
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
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
