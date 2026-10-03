import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../app/providers/preferences_providers.dart';
import '../domain/branch.dart';

part 'branch_providers.g.dart';

/// All branches.
@riverpod
List<Branch> branches(Ref ref) {
  return const [
    Branch(
      id: 'jamhuri',
      name: 'Jamhuri',
      address: 'Jamhuri Estate, Nairobi',
      phone: '0712000001',
    ),
    Branch(
      id: 'lavington',
      name: 'Lavington',
      address: 'Lavington, Nairobi',
      phone: '0712000002',
    ),
    Branch(
      id: 'kileleshwa',
      name: 'Kileleshwa',
      address: 'Kileleshwa, Nairobi',
      phone: '0712000003',
    ),
    Branch(
      id: 'nextgen',
      name: 'NextGen Mall',
      address: 'NextGen Mall, Nairobi',
      phone: '0712000004',
    ),
  ];
}

/// Branches user can access (ponytail: mock returns all, filter by user role when auth ready).
@riverpod
List<Branch> userBranches(Ref ref) {
  return ref.watch(branchesProvider);
}

/// Current selected branch (restores last selection from prefs).
@riverpod
class CurrentBranch extends _$CurrentBranch {
  @override
  Branch build() {
    final allBranches = ref.watch(branchesProvider);
    
    // Restore last selected branch from preferences
    final prefsAsync = ref.watch(preferencesServiceProvider);
    final savedBranchId = prefsAsync.whenOrNull(
      data: (service) => service.getSelectedBranchId(),
    );
    
    if (savedBranchId != null) {
      final savedBranch = allBranches.firstWhere(
        (b) => b.id == savedBranchId,
        orElse: () => allBranches.first,
      );
      return savedBranch;
    }
    
    return allBranches.first; // default: jamhuri
  }

  Future<void> select(Branch branch) async {
    state = branch;
    
    // Persist selection
    final prefsService = await ref.read(preferencesServiceProvider.future);
    await prefsService.setSelectedBranchId(branch.id);
  }
}
