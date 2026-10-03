import '../domain/staff.dart';

/// Staff repository interface.
abstract class StaffRepository {
  /// Get all staff.
  Future<List<Staff>> getStaff();
  
  /// Get staff by ID.
  Future<Staff?> getStaffById(String id);
  
  /// Get staff by branch.
  Future<List<Staff>> getStaffByBranch(String branchId);
  
  /// Add or update staff.
  Future<void> saveStaff(Staff staff);
}
