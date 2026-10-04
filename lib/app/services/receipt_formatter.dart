import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../features/sales/domain/sales_models.dart';

/// Formats sale receipts for printing/sharing.
class ReceiptFormatter {
  ReceiptFormatter({
    required this.businessName,
    required this.businessAddress,
    required this.businessPhone,
  });

  final String businessName;
  final String businessAddress;
  final String businessPhone;

  /// Formats a sale as a plain text receipt.
  /// ponytail: thermal printer format (48 chars wide), adapt for specific printer model
  String formatReceipt(Sale sale, {required String branchName, required String customerName}) {
    final buffer = StringBuffer();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Header
    buffer.writeln(_center(businessName, 48));
    buffer.writeln(_center(businessAddress, 48));
    buffer.writeln(_center(businessPhone, 48));
    buffer.writeln(_line(48));

    // Receipt info
    buffer.writeln('Receipt: ${sale.receiptNumber}');
    buffer.writeln('Date: ${dateFormat.format(sale.date)}');
    buffer.writeln('Branch: $branchName');
    buffer.writeln('Customer: $customerName');
    buffer.writeln(_line(48));

    // Items
    buffer.writeln(_formatRow('Item', 'Qty', 'Price', 'Total'));
    buffer.writeln(_line(48));

    for (final line in sale.lines) {
      final unitPriceStr = formatKes(line.unitPrice);
      final lineTotalStr = formatKes(line.total);

      // Product name on own line if too long
      if (line.productName.length > 30) {
        buffer.writeln(line.productName);
        buffer.writeln(_formatRow('', '${line.quantity}', unitPriceStr, lineTotalStr));
      } else {
        final shortName = line.productName.length > 20
            ? '${line.productName.substring(0, 17)}...'
            : line.productName;
        buffer.writeln(_formatRow(shortName, '${line.quantity}', unitPriceStr, lineTotalStr));
      }
    }

    buffer.writeln(_line(48));

    // Totals
    buffer.writeln(_rightAlign('TOTAL: ${formatKes(sale.total)}', 48));

    // Payments
    if (sale.payments.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Payments:');
      for (final payment in sale.payments) {
        final methodLabel = payment.method.name.toUpperCase();
        buffer.writeln('  $methodLabel: ${formatKes(payment.amount)}');
        if (payment.reference != null) {
          buffer.writeln('  Ref: ${payment.reference}');
        }
      }
    }

    // Balance (for credit sales)
    if (sale.status == SaleStatus.credit) {
      buffer.writeln();
      buffer.writeln(_rightAlign('BALANCE DUE: ${formatKes(sale.balance)}', 48));
      if (sale.dueDate != null) {
        buffer.writeln(_rightAlign('Due: ${dateFormat.format(sale.dueDate!)}', 48));
      }
    }
    
    // Returned cylinders
    if (sale.returnedCylinders.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Returned Cylinders:');
      for (final cylinder in sale.returnedCylinders) {
        buffer.writeln('  ${cylinder.brand} ${cylinder.sizeKg}kg x${cylinder.count}');
      }
    }
    
    // Footer
    buffer.writeln();
    buffer.writeln(_line(48));
    buffer.writeln(_center('Thank you for your business!', 48));
    buffer.writeln(_center('ID: ${sale.id}', 48));
    
    return buffer.toString();
  }

  String _center(String text, int width) {
    if (text.length >= width) return text;
    final padding = (width - text.length) ~/ 2;
    return '${' ' * padding}$text';
  }

  String _rightAlign(String text, int width) {
    if (text.length >= width) return text;
    final padding = width - text.length;
    return '${' ' * padding}$text';
  }

  String _line(int width) => '-' * width;

  String _formatRow(String col1, String col2, String col3, String col4) {
    // 48 chars: Item(20) Qty(6) Price(10) Total(12)
    return '${col1.padRight(20)} ${col2.padLeft(4)} ${col3.padLeft(9)} ${col4.padLeft(11)}';
  }
}
