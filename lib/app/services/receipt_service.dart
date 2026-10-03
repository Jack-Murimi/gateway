import 'package:flutter/services.dart';

import '../../features/sales/domain/sales_models.dart';
import 'receipt_formatter.dart';

/// Receipt printing/sharing service.
class ReceiptService {
  ReceiptService(this._formatter);

  final ReceiptFormatter _formatter;

  /// Formats and copies receipt to clipboard.
  /// ponytail: thermal printer integration (ESC/POS), PDF generation, WhatsApp share
  Future<void> shareReceipt(
    Sale sale, {
    required String branchName,
    required String customerName,
  }) async {
    final receiptText = _formatter.formatReceipt(
      sale,
      branchName: branchName,
      customerName: customerName,
    );

    // For now: copy to clipboard
    // Future: send to thermal printer, generate PDF, share via WhatsApp
    await Clipboard.setData(ClipboardData(text: receiptText));
  }

  /// Prints receipt (placeholder for thermal printer).
  /// ponytail: ESC/POS commands for specific printer model
  Future<void> printReceipt(
    Sale sale, {
    required String branchName,
    required String customerName,
  }) async {
    // Placeholder: same as share for now
    await shareReceipt(sale, branchName: branchName, customerName: customerName);
  }
}
