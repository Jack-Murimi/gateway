import '../domain/staff.dart';
import 'staff_repository.dart';

/// Mock staff repository with sample data.
class MockStaffRepository implements StaffRepository {
  MockStaffRepository() {
    _initSampleData();
  }

  final _staff = <Staff>[];

  void _initSampleData() {
    _staff.addAll([
      const Staff(
        id: 'john_kamau',
        name: 'John Kamau',
        role: UserRole.salesperson,
        branchId: 'jamhuri',
        phone: '+254712345678',
      ),
      const Staff(
        id: 'alice_director',
        name: 'Alice Mwangi',
        role: UserRole.director,
        branchId: 'jamhuri',
        phone: '+254723456789',
      ),
      const Staff(
        id: 'bob_admin',
        name: 'Bob Ochieng',
        role: UserRole.admin,
        branchId: 'all',
        phone: '+254734567890',
      ),
      const Staff(
        id: 'carol_sales',
        name: 'Carol Njeri',
        role: UserRole.salesperson,
        branchId: 'lavington',
        phone: '+254745678901',
      ),
      const Staff(
        id: 'david_rider',
        name: 'David Kipchoge',
        role: UserRole.rider,
        branchId: 'jamhuri',
        phone: '+254756789012',
      ),
    ]);
  }

  @override
  Future<List<Staff>> getStaff() async => List.unmodifiable(_staff);

  @override
  Future<Staff?> getStaffById(String id) async {
    try {
      return _staff.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Staff>> getStaffByBranch(String branchId) async {
    return _staff
        .where((s) => s.branchId == branchId || s.branchId == 'all')
        .toList();
  }

  @override
  Future<void> saveStaff(Staff staff) async {
    final idx = _staff.indexWhere((s) => s.id == staff.id);
    if (idx >= 0) {
      _staff[idx] = staff;
    } else {
      _staff.add(staff);
    }
  }
}
