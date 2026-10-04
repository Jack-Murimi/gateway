import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../design_system/components/buttons/app_button.dart';
import '../../../design_system/components/dialogs/app_dialog.dart';
import '../../../design_system/components/inputs/app_text_field.dart';
import '../../../design_system/theme/theme_extensions.dart';
import '../domain/product.dart';

/// Dialog for adding or editing a product.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({
    this.product,
    required this.onSubmit,
    super.key,
  });

  /// Product to edit (null for new product).
  final Product? product;
  
  /// Callback when form is submitted.
  final Future<void> Function(Product product) onSubmit;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  
  late ProductKind _selectedKind;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _brandController.text = p.brand ?? '';
      _priceController.text = p.price.toString();
      _sizeController.text = p.sizeKg?.toString() ?? '';
      _selectedKind = p.kind;
    } else {
      _selectedKind = ProductKind.refill;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  bool get _requiresCylinderFields =>
      _selectedKind == ProductKind.refill ||
      _selectedKind == ProductKind.emptyCylinder;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final priceKES = int.tryParse(_priceController.text.trim()) ?? 0;
    final sizeKg = _sizeController.text.isNotEmpty
        ? double.tryParse(_sizeController.text)
        : null;

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      kind: _selectedKind,
      price: priceKES,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      sizeKg: sizeKg,
    );

    try {
      await widget.onSubmit(product);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isEditing = widget.product != null;

    return AppDialog(
      title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Product Name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              DropdownButtonFormField<ProductKind>(
                initialValue: _selectedKind,
                decoration: const InputDecoration(
                  labelText: 'Product Type',
                  border: OutlineInputBorder(),
                ),
                items: ProductKind.values.map((kind) {
                  return DropdownMenuItem(
                    value: kind,
                    child: Text(_kindLabel(kind)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedKind = value;
                    });
                  }
                },
              ),
              SizedBox(height: spacing.md),
              AppTextField(
                label: 'Price (KES)',
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              if (_requiresCylinderFields) ...[
                SizedBox(height: spacing.md),
                AppTextField(
                  label: 'Brand',
                  controller: _brandController,
                  validator: (value) {
                    if (_requiresCylinderFields &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Brand is required for cylinders';
                    }
                    return null;
                  },
                ),
                SizedBox(height: spacing.md),
                AppTextField(
                  label: 'Size (kg)',
                  controller: _sizeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  validator: (value) {
                    if (_requiresCylinderFields &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Size is required for cylinders';
                    }
                    if (value != null && value.isNotEmpty) {
                      final size = double.tryParse(value);
                      if (size == null || size <= 0) {
                        return 'Enter a valid size';
                      }
                    }
                    return null;
                  },
                ),
              ] else
                SizedBox(height: spacing.md),
              AppTextField(
                label: 'Brand (optional)',
                controller: _brandController,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton(
          label: isEditing ? 'Save' : 'Add',
          onPressed: _isLoading ? null : _submit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  String _kindLabel(ProductKind kind) {
    switch (kind) {
      case ProductKind.refill:
        return 'Refill';
      case ProductKind.emptyCylinder:
        return 'Empty Cylinder';
      case ProductKind.accessory:
        return 'Accessory';
    }
  }
}
