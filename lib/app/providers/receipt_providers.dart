import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/receipt_formatter.dart';
import '../services/receipt_service.dart';

part 'receipt_providers.g.dart';

/// Provides receipt formatter.
@Riverpod(keepAlive: true)
ReceiptFormatter receiptFormatter(Ref ref) {
  // ponytail: load business details from settings/config
  return ReceiptFormatter(
    businessName: 'Gateway LPG & Accessories',
    businessAddress: 'Nairobi, Kenya',
    businessPhone: '+254 700 000 000',
  );
}

/// Provides receipt service.
@Riverpod(keepAlive: true)
ReceiptService receiptService(Ref ref) {
  final formatter = ref.watch(receiptFormatterProvider);
  return ReceiptService(formatter);
}
