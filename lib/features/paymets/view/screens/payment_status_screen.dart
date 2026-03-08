import 'dart:async';

import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/addlist/view/screens/addlist_screen.dart';
import 'package:_96_sooq/features/paymets/bloc/payment_bloc.dart';
import 'package:_96_sooq/features/root/view/screens/root_view.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/custom_button_widgets.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key, required this.transactionId});

  /// The transaction ID returned by the checkout API, used to poll status.
  final String transactionId;

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _bubbleController;
  late final Animation<double> _bubbleScale;

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _deepLinkSub;

  /// Tracks whether we've already triggered the status poll (via deep link OR
  /// manual app-resume). We only poll once automatically per screen open.
  bool _hasTriggeredCheck = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bubbleScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );

    // Reset any leftover checkout state so we show the 'Waiting…' UI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentBloc>().add(const PaymentReset());
    });

    // ── Deep link listener ────────────────────────────────────────────────
    // Paymob sends the user back to ninesixsooq://payment-callback once the
    // payment flow completes in the browser. We intercept that link here and
    // immediately poll the status API.
    _appLinks = AppLinks();
    _deepLinkSub = _appLinks.uriLinkStream.listen(_onDeepLink);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkSub?.cancel();
    _bubbleController.dispose();
    super.dispose();
  }

  /// Called when the app receives a deep link (e.g. ninesixsooq://payment-callback).
  void _onDeepLink(Uri uri) {
    if (uri.host == 'payment-callback') {
      _triggerStatusCheck();
    }
  }

  /// Fallback: if Paymob didn't deep-link us back, the app-resume lifecycle
  /// fires when the user manually switched back to the app from the browser.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Give a short delay so any pending deep link fires first.
      // If the deep link already handled it, _hasTriggeredCheck is true
      // and _triggerStatusCheck becomes a no-op.
      Future.delayed(const Duration(milliseconds: 500), _triggerStatusCheck);
    }
  }

  void _triggerStatusCheck() {
    if (_hasTriggeredCheck || !mounted) return;
    _hasTriggeredCheck = true;
    context.read<PaymentBloc>().add(
      PaymentStatusPolled(transactionId: widget.transactionId),
    );
  }

  void _pollManually() {
    if (!mounted) return;
    context.read<PaymentBloc>().add(
      PaymentStatusPolled(transactionId: widget.transactionId),
    );
  }

  void _onPrimaryPressed(PaymentState state) {
    if (state is PaymentStatusSuccess) {
      _goToRootHome();
    } else if (state is PaymentStatusFailure) {
      if (Navigator.canPop(context)) Navigator.pop(context);
    } else {
      // Pending or still waiting — poll manually
      _pollManually();
    }
  }

  Future<void> _showCancelDialog() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (shouldCancel == true && mounted) _goToAddList();
  }

  void _goToRootHome() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => RootScreen()),
    (_) => false,
  );

  void _goToAddList() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const AddlistScreen()),
    (r) => r.isFirst,
  );

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        final isWaiting = !_hasTriggeredCheck && state is PaymentInitial;
        final isLoading =
            state is PaymentStatusLoading || state is PaymentCheckoutLoading;
        final isSuccess = state is PaymentStatusSuccess;
        final isFailed = state is PaymentStatusFailure;

        return Scaffold(
          backgroundColor: Colors.grey.shade200,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 520),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: _slideTransition,
                      child: Center(
                        key: ValueKey(state.runtimeType),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildIcon(
                              isWaiting: isWaiting,
                              isLoading: isLoading,
                              isSuccess: isSuccess,
                              isFailed: isFailed,
                            ),
                            const SizedBox(height: 30),
                            _buildTitle(
                              isWaiting: isWaiting,
                              isLoading: isLoading,
                              isSuccess: isSuccess,
                              isFailed: isFailed,
                            ),
                            const SizedBox(height: 10),
                            _buildSubtitle(
                              state: state,
                              isWaiting: isWaiting,
                              isLoading: isLoading,
                              isSuccess: isSuccess,
                              isFailed: isFailed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: _slideTransition,
                    child: _buildPrimaryButton(
                      key: ValueKey('${state.runtimeType}_p'),
                      state: state,
                      isWaiting: isWaiting,
                      isLoading: isLoading,
                      isSuccess: isSuccess,
                      isFailed: isFailed,
                    ),
                  ),
                  if (!isWaiting && !isLoading) ...[
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: _slideTransition,
                      child: _buildSecondaryButton(
                        key: ValueKey('${state.runtimeType}_s'),
                        isSuccess: isSuccess,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── UI Builders ────────────────────────────────────────────────────────────

  Widget _buildIcon({
    required bool isWaiting,
    required bool isLoading,
    required bool isSuccess,
    required bool isFailed,
  }) {
    IconData icon;
    Color color;

    if (isWaiting) {
      icon = Icons.payment_rounded;
      color = const Color(0xFF6D6D6D);
    } else if (isLoading) {
      icon = Icons.hourglass_empty_rounded;
      color = const Color(0xFFFFC107);
    } else if (isSuccess) {
      icon = Icons.check_rounded;
      color = const Color(0xFF16A34A);
    } else if (isFailed) {
      icon = Icons.close_rounded;
      color = const Color(0xFFDC2626);
    } else {
      icon = Icons.schedule_rounded;
      color = const Color(0xFFFFC107);
    }

    return ScaleTransition(
      scale: _bubbleScale,
      child: Container(
        height: 140,
        width: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.10),
        ),
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
          height: 110,
          width: 110,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  child: Icon(
                    icon,
                    key: ValueKey(icon),
                    color: Colors.white,
                    size: 55,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTitle({
    required bool isWaiting,
    required bool isLoading,
    required bool isSuccess,
    required bool isFailed,
  }) {
    final localizations = AppLocalizations.of(context)!;
    final String text;
    if (isWaiting) {
      text = 'Awaiting Payment…';
    } else if (isLoading) {
      text = 'Verifying…';
    } else if (isSuccess) {
      text = 'Congratulations!';
    } else if (isFailed) {
      text = localizations.oopsText;
    } else {
      text = 'Still Processing…';
    }
    return Text(text, style: AppThemes.f22w600, textAlign: TextAlign.center);
  }

  Widget _buildSubtitle({
    required PaymentState state,
    required bool isWaiting,
    required bool isLoading,
    required bool isSuccess,
    required bool isFailed,
  }) {
    if (isSuccess) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E8EC)),
        ),
        child: Text(
          'Your post has been sent for review and will be approved within 30 minutes.',
          style: AppThemes.f14w500.copyWith(
            color: AppColors.productListingTextColor,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    String text;
    if (isWaiting) {
      text =
          'Complete the payment in Paymob.\nThe app will return automatically when done.';
    } else if (isLoading) {
      text = 'Checking your payment status…';
    } else if (isFailed) {
      final msg = (state as PaymentStatusFailure).message;
      text = msg.isNotEmpty
          ? msg
          : "Payment was not successful.\nPlease try again.";
    } else {
      text =
          'Your payment is still being processed.\nTap below to check again.';
    }
    return Text(
      text,
      style: AppThemes.f14w500.copyWith(
        color: AppColors.productListingTextColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPrimaryButton({
    required Key? key,
    required PaymentState state,
    required bool isWaiting,
    required bool isLoading,
    required bool isSuccess,
    required bool isFailed,
  }) {
    final localizations = AppLocalizations.of(context)!;
    // No button while waiting for Paymob or while a check is in flight
    if (isWaiting || isLoading) return SizedBox.shrink(key: key);

    String text;
    if (isSuccess) {
      text = 'Start Exploring';
    } else if (isFailed) {
      text = localizations.tryAgainText;
    } else {
      text = 'Check Again';
    }

    return SizedBox(
      key: key,
      width: double.infinity,
      child: CustomButton(
        onPressed: () => _onPrimaryPressed(state),
        text: text,
      ),
    );
  }

  Widget _buildSecondaryButton({required Key? key, required bool isSuccess}) {
    if (isSuccess) {
      return Text(
        "You've unlocked exclusive features",
        key: key,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      );
    }
    return TextButton(
      key: key,
      onPressed: _showCancelDialog,
      child: Text('Cancel', style: AppThemes.f16w500),
    );
  }

  Widget _slideTransition(Widget child, Animation<double> animation) {
    final tween = animation.status == AnimationStatus.reverse
        ? Tween<Offset>(begin: Offset.zero, end: const Offset(-1, 0))
        : Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero);
    return ClipRect(
      child: SlideTransition(position: tween.animate(animation), child: child),
    );
  }
}
