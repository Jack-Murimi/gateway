import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../people/domain/staff.dart';

part 'auth_providers.g.dart';

/// Mock: always authenticated.
@riverpod
bool authState(Ref ref) => true;

/// Mock: logged-in staff (salesperson at Jamhuri branch).
@riverpod
Staff currentUser(Ref ref) {
  return const Staff(
    id: 'staff-001',
    name: 'John Kamau',
    role: UserRole.salesperson,
    branchId: 'jamhuri',
    phone: '0712345678',
  );
}
