import 'package:equatable/equatable.dart';

/// Branch location.
class Branch extends Equatable {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, address, phone, isActive];
}
