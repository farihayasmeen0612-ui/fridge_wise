import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/inventory_providers.dart';
import '../../domain/models/expiry_status.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/storage_location.dart';

class FoodFormScreen extends ConsumerStatefulWidget {
  const FoodFormScreen({this.itemId, super.key});

  final String? itemId;

  @override
  ConsumerState<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends ConsumerState<FoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;

  String _unit = 'pcs';
  StorageLocation _location = StorageLocation.refrigerator;
  DateTime _purchaseDate = DateTime.now();
  DateTime? _expiryDate; // User must explicitly choose or confirm expiry date
  bool _isDirty = false;
  bool _isLoading = false;

  final List<String> _availableUnits = ['pcs', 'kg', 'g', 'L', 'ml', 'packs'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController(text: '1.0');
    _notesController = TextEditingController();

    if (widget.itemId != null) {
      final items = ref.read(inventoryNotifierProvider);
      final existing = items.cast<FoodItem?>().firstWhere(
            (i) => i?.id == widget.itemId,
            orElse: () => null,
          );
      if (existing != null) {
        _nameController.text = existing.name;
        _quantityController.text = (existing.quantity % 1 == 0
                ? existing.quantity.toInt()
                : existing.quantity)
            .toString();
        _unit = existing.unit;
        _location = existing.storageLocation;
        _purchaseDate = existing.purchaseDate;
        _expiryDate = existing.expiryDate;
        _notesController.text = existing.notes ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final now = DateTime.now();
    final initial = isExpiry
        ? (_expiryDate ?? now.add(const Duration(days: 7)))
        : _purchaseDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (picked != null) {
      setState(() {
        _isDirty = true;
        if (isExpiry) {
          _expiryDate = picked;
        } else {
          _purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiration date. Expiry dates cannot be assumed silently.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final existing = widget.itemId != null
        ? ref.read(inventoryNotifierProvider).cast<FoodItem?>().firstWhere(
              (i) => i?.id == widget.itemId,
              orElse: () => null,
            )
        : null;

    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
    final id = widget.itemId ?? 'item-${DateTime.now().microsecondsSinceEpoch}';

    final foodItem = FoodItem(
      id: id,
      name: _nameController.text.trim(),
      storageLocation: _location,
      purchaseDate: _purchaseDate,
      expiryDate: _expiryDate!,
      quantity: quantity,
      unit: _unit,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      imageUrl: existing?.imageUrl,
      status: existing?.status ?? ItemStatus.active,
    );

    if (widget.itemId != null) {
      await ref.read(inventoryNotifierProvider.notifier).updateItem(foodItem);
    } else {
      await ref.read(inventoryNotifierProvider.notifier).addItem(foodItem);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;
    final discard = await AppConfirmDialog.show(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes in this form. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      isDestructive: true,
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.itemId != null;
    final dateFormat = DateFormat('MMM d, yyyy');

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Food Item' : 'Add Food Item'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _handleSave,
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              onChanged: () => _isDirty = true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name
                  AppTextField(
                    label: 'Food Item Name *',
                    controller: _nameController,
                    hintText: 'e.g. Organic Almond Milk',
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.restaurant_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter food name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity and Unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          label: 'Quantity *',
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.scale_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter quantity';
                            }
                            final n = double.tryParse(val.trim());
                            if (n == null || n <= 0) {
                              return 'Must be > 0';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _unit,
                                  isExpanded: true,
                                  items: _availableUnits.map((u) {
                                    return DropdownMenuItem(value: u, child: Text(u));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _unit = val;
                                        _isDirty = true;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Expiry Date Picker (Mandatory User Confirmation)
                  Text(
                    'Expiration Date *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _pickDate(isExpiry: true),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: _expiryDate == null
                            ? colors.warningContainer.withValues(alpha: 0.3)
                            : colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _expiryDate == null
                              ? colors.warningAmber
                              : colors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_available_rounded,
                            size: 20,
                            color: _expiryDate == null
                                ? colors.warningAmber
                                : colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _expiryDate != null
                                  ? dateFormat.format(_expiryDate!.toLocal())
                                  : 'Tap to explicitly set expiry date',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _expiryDate != null
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _expiryDate != null
                                    ? colorScheme.onSurface
                                    : colors.warningAmber,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 20, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User confirmation required. System will not assume silent expiry dates.',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 18),

                  // Purchase Date Picker
                  Text(
                    'Date Added (Purchase Date)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () => _pickDate(isExpiry: false),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 18, color: colors.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            dateFormat.format(_purchaseDate.toLocal()),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_calendar_outlined, size: 18, color: colors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Storage Location Selector
                  Text(
                    'Storage Compartment',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: StorageLocation.values.map((loc) {
                      final isSelected = _location == loc;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => setState(() {
                              _location = loc;
                              _isDirty = true;
                            }),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colors.cardBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    loc.icon,
                                    size: 20,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : colorScheme.onSurface,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Storage Notes
                  AppTextField(
                    label: 'Storage Notes & Preparation Hints',
                    controller: _notesController,
                    hintText: 'e.g. Keep chilled in crisper drawer',
                    maxLines: 2,
                    prefixIcon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  AppButton(
                    label: isEditing ? 'Save Changes' : 'Add to Fridge',
                    onPressed: _handleSave,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
