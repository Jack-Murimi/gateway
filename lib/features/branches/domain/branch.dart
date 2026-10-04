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

  Branch copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    bool? isActive,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, address, phone, isActive];
}
