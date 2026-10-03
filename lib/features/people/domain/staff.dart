import 'package:equatable/equatable.dart';

/// User role.
enum UserRole { admin, director, salesperson, rider }

/// Staff member.
class Staff extends Equatable {
  const Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.branchId,
    this.phone,
    this.isActive = true,
  });

  final String id;
  final String name;
  final UserRole role;
  final String branchId;
  final String? phone;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, role, branchId, phone, isActive];
}
