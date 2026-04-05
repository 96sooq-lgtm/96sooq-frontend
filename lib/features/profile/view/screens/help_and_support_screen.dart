import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static const _phone = '+96877228181';
  static const _whatsApp = '96877228181';
  static const _email = 'Support@96sooq.com';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── Header ──
              Row(
                children: [
                  BackButtonWidget(ontap: () => Navigator.pop(context)),
                  Expanded(
                    child: Center(
                      child: Text(
                        localizations.helpSupportTitle,
                        style: AppThemes.f18w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // balance the back button
                ],
              ),
              const SizedBox(height: 32),

              // ── Subtitle ──
              Text(localizations.howCanWeHelpYou, style: AppThemes.f18w600),
              const SizedBox(height: 8),
              Text(
                localizations.supportTeamDescription,
                style: AppThemes.f14w400.copyWith(
                  color: const Color(0xFF6E7A8A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // ── WhatsApp Support ──
              _SupportCard(
                icon: Icons.chat_outlined,
                iconColor: const Color(0xFF25D366),
                title: localizations.whatsappSupport,
                subtitle: localizations.fastestResponseTime,
                buttonLabel: localizations.chatNow,
                buttonIcon: Icons.send_rounded,
                buttonColor: const Color(0xFF25D366),
                onTap: () {
                  launchUrl(
                    Uri.parse('https://wa.me/$_whatsApp'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Email Support ──
              _SupportCard(
                icon: Icons.mail_outline_rounded,
                iconColor: Color(0xFFF97316),
                title: localizations.emailSupport,
                subtitle: _email,
                buttonLabel: localizations.emailUs,
                buttonIcon: Icons.alternate_email_rounded,
                buttonColor: Color(0xFFF97316),
                onTap: () {
                  launchUrl(
                    Uri.parse('mailto:$_email'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Call Support ──
              _SupportCard(
                icon: Icons.phone_outlined,
                iconColor: Color(0xFF2563EB),
                title: localizations.callSupport,
                subtitle: localizations.speakWithOurTeam,
                extraInfo: '+968 7722 8181',
                buttonLabel: localizations.callNow,
                buttonIcon: Icons.phone_in_talk_rounded,
                buttonColor: Color(0xFF2563EB),
                onTap: () {
                  launchUrl(
                    Uri.parse('tel:$_phone'),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Support Card Widget ─────────────────────────────────────────────────────

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.buttonColor,
    required this.onTap,
    this.extraInfo,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final Color buttonColor;
  final VoidCallback onTap;
  final String? extraInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 10),
              Text(title, style: AppThemes.f16w600),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              subtitle,
              style: AppThemes.f14w400.copyWith(color: const Color(0xFF6E7A8A)),
            ),
          ),
          if (extraInfo != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Text(
                extraInfo!,
                style: AppThemes.f14w600.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: buttonColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(buttonIcon, color: buttonColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    buttonLabel,
                    style: AppThemes.f14w600.copyWith(color: buttonColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
