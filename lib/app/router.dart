import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'shell/app_shell.dart';
import 'shell/error_page.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/application/auth_providers.dart';
import '../features/people/domain/staff.dart';
import '../features/sales/presentation/sales_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import '../features/customers/presentation/customers_screen.dart';
import '../features/suppliers/presentation/suppliers_screen.dart';
import '../features/people/presentation/people_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/sales_history/presentation/sales_history_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/branches/presentation/branch_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final isAuth = container.read(authStateProvider);
    final location = state.matchedLocation;

    // Not authenticated → login
    if (!isAuth && location != '/login') return '/login';
    
    // Authenticated on login → sales
    if (isAuth && location == '/login') return '/sales';

    // Role guards (admin/director only)
    if (isAuth) {
      final user = container.read(currentUserProvider);
      
      if (location == '/branches' && user.role != UserRole.admin) {
        return '/sales';
      }
      
      if ((location == '/staff' || location == '/reports') &&
          user.role != UserRole.admin && user.role != UserRole.director) {
        return '/sales';
      }
    }

    return null;
  },
  errorBuilder: (context, state) => ErrorPage(error: state.error),
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/sales',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(
        child: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/sales',
              builder: (context, state) => const SalesScreen(),
            ),
            GoRoute(
              path: '/history',
              builder: (context, state) => const SalesHistoryScreen(),
            ),
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryScreen(),
            ),
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomersScreen(),
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
            GoRoute(
              path: '/suppliers',
              builder: (context, state) => const SuppliersScreen(),
            ),
            GoRoute(
              path: '/staff',
              builder: (context, state) => const PeopleScreen(),
            ),
            GoRoute(
              path: '/branches',
              builder: (context, state) => const BranchManagementScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  // ponytail: refreshListenable skipped, add when auth can change during session (logout, token refresh)
);
