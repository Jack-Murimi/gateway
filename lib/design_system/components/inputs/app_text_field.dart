import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.errorText,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
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

  /// Optional trailing widget.
  final Widget? suffixIcon;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action.
  final TextInputAction? textInputAction;

  /// Called when text changes.
  final ValueChanged<String>? onChanged;

  /// Called when submitted.
  final ValueChanged<String>? onSubmitted;

  /// Called when tapped.
  final VoidCallback? onTap;

  /// Validation function.
  final FormFieldValidator<String>? validator;

  /// Error text override.
  final String? errorText;

  /// Input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum lines.
  final int? maxLines;

  /// Maximum length.
  final int? maxLength;

  /// Auto-focus on build.
  final bool autofocus;

  /// Read-only mode.
  final bool readOnly;

  /// Whether input is enabled.
  final bool enabled;

  /// Whether text is obscured.
  final bool obscureText;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Autofill hints.
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: enabled,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Search input with design-system styling.
class AppSearchField extends StatefulWidget {
  /// Creates an app search field.
  const AppSearchField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
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

  /// Called when submitted.
  final ValueChanged<String>? onSubmitted;

  /// Optional hint text.
  final String? hintText;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _effectiveController,
      builder: (context, value, child) {
        return AppTextField(
          label: widget.label,
          hintText: widget.hintText,
          controller: _effectiveController,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          prefixIcon: Icons.search,
          textInputAction: TextInputAction.search,
          suffixIcon: value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _effectiveController.clear();
                    widget.onChanged?.call('');
                  },
                )
              : null,
        );
      },
    );
  }
}
