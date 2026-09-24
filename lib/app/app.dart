import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

/// Root Gateway application widget.
class GatewayApp extends StatelessWidget {
  /// Creates the Gateway app.
  const GatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gateway POS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
