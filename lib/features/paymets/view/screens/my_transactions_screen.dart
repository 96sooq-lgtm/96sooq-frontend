import 'package:_96_sooq/constants/app_colors.dart';
import 'package:_96_sooq/constants/app_themes.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/paymets/bloc/transactions_bloc.dart';
import 'package:_96_sooq/features/paymets/data/invoice_pdf_service.dart';
import 'package:_96_sooq/features/paymets/model/transaction_model.dart';
import 'package:_96_sooq/l10n/app_localizations.dart';
import 'package:_96_sooq/shared/global_widgets/backnavigation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MyTransactionsScreen extends StatelessWidget {
  const MyTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => TransactionsBloc()..add(const TransactionsFetched()),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    BackButtonWidget(ontap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    Text('Transaction History', style: AppThemes.f18w600),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Business Expenses', style: AppThemes.f18w600),
                    const SizedBox(height: 4),
                    Text(
                      'Download invoices for your tax records',
                      style: AppThemes.f14w400.copyWith(
                        color: const Color(0xFF6E7A8A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Transaction List ──
              Expanded(
                child: BlocBuilder<TransactionsBloc, TransactionsState>(
                  builder: (context, state) {
                    if (state.status == TransactionsStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (state.status == TransactionsStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Color(0xFFCB3A31),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Could not load transactions',
                                style: AppThemes.f16w600,
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => context
                                    .read<TransactionsBloc>()
                                    .add(const TransactionsFetched()),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: AppThemes.f14w600.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final transactions = state.transactions;

                    if (transactions.isEmpty) {
                      return Center(
                        child: Text(
                          localizations.noTransactionsTitle,
                          style: AppThemes.f16w500.copyWith(
                            color: AppColors.productListingTextColor,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _TransactionCard(
                          transaction: transactions[index],
                          onDownload: () =>
                              _downloadInvoice(context, transactions[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _downloadInvoice(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating invoice...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final user = await AuthSessionRepository().getCachedUser();
      await const InvoicePdfService().generateAndOpen(
        transaction: transaction,
        user: user!,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate invoice: $e')));
    }
  }
}

// ─── Transaction Card ────────────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onDownload});
  final TransactionModel transaction;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'MMM dd, yyyy • HH:mm',
    ).format(transaction.createdAt.toLocal());

    // Icon and color based on label
    final IconData icon;
    final Color iconColor;
    if (transaction.displayLabel.contains('Ad') ||
        transaction.displayLabel.contains('Top Offer')) {
      icon = Icons.bolt;
      iconColor = const Color(0xFF4338CA);
    } else if (transaction.displayLabel.contains('Listing')) {
      icon = Icons.upload_rounded;
      iconColor = const Color(0xFF4338CA);
    } else {
      icon = Icons.receipt_long_rounded;
      iconColor = const Color(0xFF4338CA);
    }

    // Status badge
    final Color statusColor;
    final String statusText;
    if (transaction.isSuccess) {
      statusColor = const Color(0xFF10B44A);
      statusText = 'PAID';
    } else if (transaction.isPending) {
      statusColor = const Color(0xFFE79718);
      statusText = 'PENDING';
    } else {
      statusColor = const Color(0xFFCB3A31);
      statusText = 'FAILED';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              // Label + Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.displayLabel, style: AppThemes.f16w600),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: AppThemes.f12w500.copyWith(
                        color: const Color(0xFF6E7A8A),
                      ),
                    ),
                  ],
                ),
              ),
              // Amount + Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.amount.toStringAsFixed(3)} ${transaction.currency}',
                    style: AppThemes.f16w600,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: AppThemes.f12w700.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
          ),
          if (transaction.isSuccess) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F3F5)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inv #${transaction.id.substring(0, 8).toUpperCase()}',
                  style: AppThemes.f12w500.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: onDownload,
                  child: Row(
                    children: [
                      Icon(
                        Icons.download_rounded,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Download Invoice',
                        style: AppThemes.f12w600.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
