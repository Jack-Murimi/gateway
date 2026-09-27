import 'package:flutter/material.dart';

/// Design-system text field wrapper.
class AppTextField extends StatelessWidget {
  /// Creates an app text field.
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.semanticLabel,
  });

  /// Field label.
  final String label;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Focus node.
  final FocusNode? focusNode;

  /// Optional hint text.
  final String? hintText;

  /// Optional leading icon.
  final IconData? prefixIcon;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action.
  final TextInputAction? textInputAction;

  /// Called when text changes.
  final ValueChanged<String>? onChanged;

  /// Whether input is enabled.
  final bool enabled;

  /// Whether text is obscured.
  final bool obscureText;

  /// Accessible label override.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? label,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        enabled: enabled,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        ),
      ),
    );
  }
}

/// Search input with design-system styling.
class AppSearchField extends StatelessWidget {
  /// Creates an app search field.
  const AppSearchField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText,
  });

  /// Search label.
  final String label;

  /// Text editing controller.
  final TextEditingController? controller;

  /// Focus node.
  final FocusNode? focusNode;

  /// Called when query changes.
  final ValueChanged<String>? onChanged;

  /// Optional hint text.
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      prefixIcon: Icons.search,
      textInputAction: TextInputAction.search,
      semanticLabel: label,
    );
  }
}
