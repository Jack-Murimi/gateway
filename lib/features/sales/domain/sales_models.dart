import 'package:equatable/equatable.dart';
import '../../inventory/domain/product.dart';
import 'returned_cylinder.dart';

/// Sale status.
enum SaleStatus { draft, completed, credit, voided, cancelled }

/// Payment method.
enum PaymentMethod { cash, mpesa, bank, credit }

/// Cart line item (holds Product reference).
class SaleLineItem extends Equatable {
  const SaleLineItem({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final int quantity;

  int get total => product.price * quantity;

  SaleLineItem copyWith({int? quantity}) => SaleLineItem(
        product: product,
        quantity: quantity ?? this.quantity,
      );

  /// Convert to persisted line.
  SaleLine toSaleLine() => SaleLine(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: quantity,
      );

  @override
  List<Object?> get props => [product, quantity];
}

/// Sale line item (persisted).
class SaleLine extends Equatable {
  const SaleLine({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final int unitPrice;
  final int quantity;

  int get total => unitPrice * quantity;

  SaleLine copyWith({int? quantity}) => SaleLine(
        productId: productId,
        productName: productName,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [productId, productName, unitPrice, quantity];
}

/// Payment.
class Payment extends Equatable {
  const Payment({
    required this.method,
    required this.amount,
    required this.timestamp,
    this.reference,
  });

  final PaymentMethod method;
  final int amount;
  final DateTime timestamp;
  final String? reference;

  @override
  List<Object?> get props => [method, amount, timestamp, reference];
}

/// Completed sale.
class Sale extends Equatable {
  const Sale({
    required this.id,
    required this.receiptNumber,
    required this.date,
    required this.branchId,
    required this.customerId,
    this.customerLocationId,
    required this.lines,
    required this.payments,
    required this.status,
    this.returnedCylinders = const [],
    required this.cashierId,
    required this.createdAt,
    this.dueDate,
    this.voidReason,
    this.voidedBy,
    this.voidedAt,
  });

  final String id;
  final String receiptNumber;
  final DateTime date;
  final String branchId;
  final String customerId;
  final String? customerLocationId;
  final List<SaleLine> lines;
  final List<Payment> payments;
  final SaleStatus status;
  final List<ReturnedCylinder> returnedCylinders;
  final String cashierId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? voidReason;
  final String? voidedBy;
  final DateTime? voidedAt;

  int get total => lines.fold<int>(0, (sum, item) => sum + item.total);
  int get totalPaid => payments.fold<int>(0, (sum, p) => sum + p.amount);
  int get balance => total - totalPaid;

  @override
  List<Object?> get props => [
        id,
        receiptNumber,
        date,
        branchId,
        customerId,
        customerLocationId,
        lines,
        payments,
        status,
        returnedCylinders,
        cashierId,
        createdAt,
        dueDate,
        voidReason,
        voidedBy,
        voidedAt,
      ];
}
