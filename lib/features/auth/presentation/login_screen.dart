import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../../branches/application/branch_providers.dart';
import '../../branches/presentation/widgets/branch_selection_dialog.dart';
import '../../sales/presentation/sales_screen.dart';

/// Login screen with email/password authentication.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const LoginScreen({super.key});

  /// Route path.
  static const String routePath = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  var _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      !_isLoading;

  Future<void> _handleLogin() async {
    // Validate
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'Email is required' : null;
      _passwordError = password.isEmpty ? 'Password is required' : null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    // ponytail: mock auth delay, replace with real auth service when backend ready
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    final branches = ref.read(userBranchesProvider);
    if (branches.length == 1) {
      // Auto-select single branch
      ref.read(currentBranchProvider.notifier).select(branches.first);
      if (mounted) context.go(SalesScreen.routePath);
    } else {
      // Show selection dialog
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const BranchSelectionDialog(),
      );
      if (mounted) context.go(SalesScreen.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: spacing.page,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  SizedBox(height: spacing.lg),
                  Text(
                    'Gateway POS',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.sm),
                  Text(
                    'LPG & Accessories Multi-Branch',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.xl),
                  AppTextField(
                    label: 'Email',
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.email_outlined,
                    enabled: !_isLoading,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),
                  SizedBox(height: spacing.md),
                  AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outlined,
                    enabled: !_isLoading,
                    errorText: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onSubmitted: (_) {
                      if (_canSubmit) _handleLogin();
                    },
                  ),
                  SizedBox(height: spacing.lg),
                  AppButton(
                    label: 'Sign In',
                    onPressed: _canSubmit ? _handleLogin : null,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
