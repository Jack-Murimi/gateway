import 'package:equatable/equatable.dart';

/// Supplier entity.
///
/// Balance semantics:
/// - Negative = we owe the supplier (received goods, unpaid)
/// - Positive = supplier owes us (overpayment/returns)
/// - Zero = settled
class Supplier extends Equatable {
  /// Creates a supplier.
  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.balance,
    this.lastOrderDate,
    this.deletedAt,
  });

  /// Unique identifier.
  final String id;

  /// Supplier name.
  final String name;

  /// Phone number.
  final String phone;

  /// Email address (optional).
  final String? email;

  /// Balance in KES minor units (cents).
  /// Negative = we owe them, Positive = they owe us.
  final int balance;

  /// Last order date (ISO 8601).
  final String? lastOrderDate;

  /// Soft delete timestamp for audit trail.
  /// Null = active, non-null = deleted but preserved for history.
  final DateTime? deletedAt;

  /// Whether this supplier is active (not deleted).
  bool get isActive => deletedAt == null;

  /// Creates a copy with updated fields.
  Supplier copyWith({
    String? name,
    String? phone,
    String? email,
    int? balance,
    String? lastOrderDate,
    DateTime? deletedAt,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      balance: balance ?? this.balance,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, balance, lastOrderDate, deletedAt];
}
