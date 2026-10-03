import 'package:equatable/equatable.dart';

/// Customer model.
class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    required this.phones,
    this.locations = const [],
    this.balance = 0,
    this.creditLimit,
    this.emptiesOwed = 0,
  });

  final String id;
  final String name;
  final List<String> phones;
  final List<CustomerLocation> locations;
  final int balance;
  final int? creditLimit;
  final int emptiesOwed;

  /// Walk-in customer singleton.
  static const walkIn = Customer(
    id: 'walk-in',
    name: 'Walk-in Customer',
    phones: [],
  );

  /// Backwards-compat: check if walk-in.
  bool get isWalkIn => id == 'walk-in';

  /// Backwards-compat: primary phone (first in list or empty).
  String get phone => phones.isEmpty ? '' : phones.first;

  @override
  List<Object?> get props => [id, name, phones, locations, balance, creditLimit, emptiesOwed];
}

/// Customer delivery location.
class CustomerLocation extends Equatable {
  const CustomerLocation({
    required this.id,
    required this.address,
    this.isDefault = false,
  });

  final String id;
  final String address;
  final bool isDefault;

  @override
  List<Object?> get props => [id, address, isDefault];
}
