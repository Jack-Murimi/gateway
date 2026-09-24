import 'package:go_router/go_router.dart';

import '../features/pos/presentation/pos_foundation_screen.dart';

/// App router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: PosFoundationScreen.routePath,
  routes: [
    GoRoute(
      path: PosFoundationScreen.routePath,
      builder: (context, state) => const PosFoundationScreen(),
    ),
  ],
);
