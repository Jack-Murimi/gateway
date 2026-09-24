import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/cards/stat_card.dart';
import '../../../design_system/components/feedback/feedback_views.dart';
import '../../../design_system/components/layout/section_header.dart';
import '../../../design_system/components/navigation/app_scaffold.dart';
import '../../../design_system/components/navigation/branch_selector.dart';
import '../../../design_system/components/products/product_card.dart';
import '../../../design_system/components/status/status_badge.dart';
import '../../../design_system/theme/theme_extensions.dart';

/// Temporary foundation screen proving the design system shell.
class PosFoundationScreen extends StatelessWidget {
  /// Creates the POS foundation screen.
  const PosFoundationScreen({super.key});

  /// Route path for the foundation screen.
  static const String routePath = '/';

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final currency = NumberFormat.simpleCurrency(name: 'KES');
    final branches = const [
      BranchOption(id: 'main', name: 'Main Branch'),
      BranchOption(id: 'west', name: 'Westlands'),
    ];

    return AppScaffold(
      title: 'Gateway POS',
      selectedIndex: AppNavigationIndex.pos,
      onDestinationSelected: (_) {},
      destinations: const [
        AppNavDestination(label: 'POS', icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale),
        AppNavDestination(label: 'Inventory', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2),
        AppNavDestination(label: 'Reports', icon: Icons.query_stats_outlined, selectedIcon: Icons.query_stats),
      ],
      actions: [
        Padding(
          padding: spacing.compact,
          child: BranchSelector(
            branches: branches,
            selectedBranchId: branches.first.id,
            onChanged: (_) {},
          ),
        ),
      ],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppFoundationBreakpoints.wide;
          final content = _FoundationContent(currency: currency, isWide: isWide);

          return SingleChildScrollView(
            padding: spacing.page,
            child: content,
          );
        },
      ),
    );
  }
}

class _FoundationContent extends StatelessWidget {
  const _FoundationContent({required this.currency, required this.isWide});

  final NumberFormat currency;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OfflineBanner(),
        SizedBox(height: spacing.lg),
        const SectionHeader(
          title: 'Design foundation ready',
          subtitle: 'Material 3 theme, tokens, adaptive shell, and core POS components are wired.',
        ),
        SizedBox(height: spacing.lg),
        _StatsGrid(isWide: isWide, currency: currency),
        SizedBox(height: spacing.xl),
        Wrap(
          spacing: spacing.lg,
          runSpacing: spacing.lg,
          children: [
            SizedBox(
              width: isWide ? AppFoundationBreakpoints.cardWidth : double.infinity,
              child: ProductCard(
                name: '13kg LPG Cylinder Refill',
                price: currency.format(AppFoundationValues.refillPrice),
                stockLabel: 'In stock',
                status: AppStatus.success,
              ),
            ),
            SizedBox(
              width: isWide ? AppFoundationBreakpoints.cardWidth : double.infinity,
              child: ProductCard(
                name: 'Burner Regulator Kit',
                price: currency.format(AppFoundationValues.regulatorPrice),
                stockLabel: 'Low stock',
                status: AppStatus.warning,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.xl),
        const EmptyView(
          title: 'Login and POS screens next',
          message: 'The reusable UI foundation is ready for feature composition.',
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.isWide, required this.currency});

  final bool isWide;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final width = isWide ? AppFoundationBreakpoints.cardWidth : double.infinity;

    return Wrap(
      spacing: spacing.lg,
      runSpacing: spacing.lg,
      children: [
        SizedBox(
          width: width,
          child: StatCard(
            label: 'Today sales',
            value: currency.format(AppFoundationValues.sales),
            icon: Icons.payments_outlined,
            supportingText: 'Main Branch',
          ),
        ),
        SizedBox(
          width: width,
          child: const StatCard(
            label: 'Open carts',
            value: '3',
            icon: Icons.shopping_cart_outlined,
            supportingText: 'Presentation mock data',
          ),
        ),
      ],
    );
  }
}

/// Navigation indexes used by the placeholder shell.
abstract final class AppNavigationIndex {
  /// POS destination index.
  static const int pos = 0;
}

/// Temporary foundation breakpoint values.
abstract final class AppFoundationBreakpoints {
  /// Wide layout threshold.
  static const double wide = 720;

  /// Demo card width.
  static const double cardWidth = 280;
}

/// Temporary mock values for formatting and layout smoke tests.
abstract final class AppFoundationValues {
  /// Mock sales total.
  static const num sales = 48200;

  /// Mock refill price.
  static const num refillPrice = 3300;

  /// Mock regulator price.
  static const num regulatorPrice = 1250;
}
