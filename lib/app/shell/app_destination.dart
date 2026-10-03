import 'package:flutter/material.dart';

import '../../features/people/domain/staff.dart';

/// Navigation destination for app shell.
class AppDestination {
  const AppDestination({
    required this.path,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.requiredRole,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final UserRole? requiredRole;

  /// Check if user role can access this destination.
  bool canAccess(UserRole userRole) {
    if (requiredRole == null) return true;
    return _roleIndex(userRole) >= _roleIndex(requiredRole!);
  }

  static int _roleIndex(UserRole role) {
    switch (role) {
      case UserRole.rider: return 0;
      case UserRole.salesperson: return 1;
      case UserRole.director: return 2;
      case UserRole.admin: return 3;
    }
  }
}
