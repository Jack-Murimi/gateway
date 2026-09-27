import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/sales/presentation/sales_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import '../features/customers/presentation/customers_screen.dart';
import '../features/suppliers/presentation/suppliers_screen.dart';
import '../features/people/presentation/people_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/sales_history/presentation/sales_history_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/branches/presentation/branch_management_screen.dart';

/// App router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: LoginScreen.routePath,
  routes: [
    GoRoute(
      path: LoginScreen.routePath,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: SalesScreen.routePath,
      builder: (context, state) => const SalesScreen(),
    ),
    GoRoute(
      path: InventoryScreen.routePath,
      builder: (context, state) => const InventoryScreen(),
    ),
    GoRoute(
      path: CustomersScreen.routePath,
      builder: (context, state) => const CustomersScreen(),
    ),
    GoRoute(
      path: SuppliersScreen.routePath,
      builder: (context, state) => const SuppliersScreen(),
    ),
    GoRoute(
      path: PeopleScreen.routePath,
      builder: (context, state) => const PeopleScreen(),
    ),
    GoRoute(
      path: ReportsScreen.routePath,
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: SalesHistoryScreen.routePath,
      builder: (context, state) => const SalesHistoryScreen(),
    ),
    GoRoute(
      path: SettingsScreen.routePath,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: BranchManagementScreen.routePath,
      builder: (context, state) => const BranchManagementScreen(),
    ),
  ],
);
