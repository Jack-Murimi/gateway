import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mock_staff_repository.dart';
import '../data/staff_repository.dart';
import '../domain/staff.dart';

part 'staff_providers.g.dart';

/// Staff repository.
@riverpod
StaffRepository staffRepository(Ref ref) {
  return MockStaffRepository();
}

/// All staff list.
@riverpod
Future<List<Staff>> staffList(Ref ref) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getStaff();
}

/// Staff filtered by branch.
@riverpod
Future<List<Staff>> branchStaff(Ref ref, String branchId) async {
  final repo = ref.watch(staffRepositoryProvider);
  return repo.getStaffByBranch(branchId);
}
