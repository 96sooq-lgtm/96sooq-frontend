import 'dart:io';

import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart';
import 'package:_96_sooq/features/paymets/model/transaction_model.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class InvoicePdfService {
  const InvoicePdfService();

  /// Loads Poppins font from bundled assets for proper Unicode support.
  Future<pw.ThemeData> _loadTheme() async {
    final regularData = await rootBundle.load(
      'assets/fonts/poppins/Poppins-Regular.ttf',
    );
    final boldData = await rootBundle.load(
      'assets/fonts/poppins/Poppins-SemiBold.ttf',
    );
    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);

    return pw.ThemeData.withFont(base: regular, bold: bold);
  }

  /// Generates a professional invoice PDF and saves it to the device.
  /// Returns the file path of the saved PDF.
  Future<String> generateAndSave({
    required TransactionModel transaction,
    required AuthUser user,
  }) async {
    final theme = await _loadTheme();
    final pdf = pw.Document(theme: theme);

    final invoiceNumber = 'INV-${transaction.id.substring(0, 8).toUpperCase()}';
    final dateStr = DateFormat(
      'MMM dd, yyyy',
    ).format(transaction.createdAt.toLocal());
    final amountStr =
        '${transaction.amount.toStringAsFixed(3)} ${transaction.currency}';
    final primaryColor = PdfColor.fromHex('#1A56DB');
    final darkColor = PdfColor.fromHex('#111827');
    final greyColor = PdfColor.fromHex('#6B7280');
    final lightGrey = PdfColor.fromHex('#F3F4F6');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Header ──
              pw.Center(
                child: pw.Text(
                  'Invoice',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // ── Company + Invoice Details row ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Company info
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '96 Sooq Oman',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Muscat, Sultanate of Oman',
                        style: pw.TextStyle(fontSize: 11, color: greyColor),
                      ),
                    ],
                  ),
                  // Invoice details
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE DETAILS',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '#$invoiceNumber',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        dateStr,
                        style: pw.TextStyle(fontSize: 11, color: greyColor),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // ── Bill To ──
              pw.Text(
                'BILL TO',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightGrey,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      user.name.isNotEmpty ? user.name : 'Customer',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    if (user.email.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        user.email,
                        style: pw.TextStyle(fontSize: 11, color: greyColor),
                      ),
                    ],
                    if (user.phoneNumber.isNotEmpty) ...[
                      pw.SizedBox(height: 2),
                      pw.Text(
                        user.phoneNumber,
                        style: pw.TextStyle(fontSize: 11, color: greyColor),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // ── Line Items Table ──
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColor.fromHex('#E5E7EB')),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    // Table Header
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: pw.BoxDecoration(
                        color: lightGrey,
                        borderRadius: const pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(8),
                          topRight: pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              'DESCRIPTION',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 60,
                            child: pw.Center(
                              child: pw.Text(
                                'QTY',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 100,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                'PRICE',
                                style: pw.TextStyle(
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table Row
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  transaction.displayLabel,
                                  style: pw.TextStyle(
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                    color: darkColor,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  _getDescription(transaction),
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(
                            width: 60,
                            child: pw.Center(
                              child: pw.Text(
                                '1',
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  color: darkColor,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 100,
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                amountStr,
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  color: darkColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // ── Totals ──
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Subtotal',
                            style: pw.TextStyle(fontSize: 12, color: greyColor),
                          ),
                          pw.Text(
                            amountStr,
                            style: pw.TextStyle(fontSize: 12, color: darkColor),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Divider(color: PdfColor.fromHex('#E5E7EB')),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Total',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                          pw.Text(
                            amountStr,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // ── Payment Status Badge ──
              if (transaction.isSuccess)
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(20),
                      border: pw.Border.all(color: PdfColor.fromHex('#10B44A')),
                    ),
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(
                          width: 8,
                          height: 8,
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('#10B44A'),
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'PAID IN FULL',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#10B44A'),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              pw.Spacer(),

              // ── Footer ──
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'THIS IS A COMPUTER GENERATED INVOICE',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: greyColor,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'AND DOES NOT REQUIRE A PHYSICAL SIGNATURE.',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: greyColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/invoice_${transaction.id.substring(0, 8)}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// Opens the generated PDF in the device's default viewer.
  Future<void> generateAndOpen({
    required TransactionModel transaction,
    required AuthUser user,
  }) async {
    final path = await generateAndSave(transaction: transaction, user: user);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path)], text: 'Invoice'),
    );
  }

  String _getDescription(TransactionModel transaction) {
    if (transaction.displayLabel.contains('Ad')) {
      return 'Top offers promotional slot';
    }
    if (transaction.displayLabel.contains('Listing')) {
      return 'Listing publication fee';
    }
    return 'Service payment';
  }
}
