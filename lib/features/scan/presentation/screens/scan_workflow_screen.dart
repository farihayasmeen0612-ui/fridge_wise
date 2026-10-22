import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../inventory/domain/models/food_category.dart';
import '../../../inventory/domain/models/food_item.dart';
import '../../../inventory/domain/models/storage_location.dart';

enum ScanStep {
  chooseOperation,
  captureImage,
  processing,
  reviewPrediction,
  confirmOperation,
}

class ScanWorkflowScreen extends ConsumerStatefulWidget {
  const ScanWorkflowScreen({this.initialMode = 'in', super.key});

  final String initialMode; // 'in' or 'out'

  @override
  ConsumerState<ScanWorkflowScreen> createState() => _ScanWorkflowScreenState();
}

class _ScanWorkflowScreenState extends ConsumerState<ScanWorkflowScreen> {
  late String _mode; // 'in' or 'out'
  ScanStep _currentStep = ScanStep.chooseOperation;

  // Recognized / Edit State
  final String _predictedName = 'Fresh Organic Strawberries';
  final FoodCategory _predictedCategory = FoodCategory.produce;
  final StorageLocation _selectedLocation = StorageLocation.fridge;
  String _unit = 'packs';
  DateTime? _confirmedExpiryDate;
  FoodItem? _selectedOutItem; // For OUT mode: existing item in fridge

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode.toLowerCase() == 'out' ? 'out' : 'in';
    _currentStep = ScanStep.captureImage; // Quick jump to capture since mode is passed
    _nameController.text = _predictedName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _simulateCapture() async {
    setState(() => _currentStep = ScanStep.processing);

    // Simulate inference time
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    if (_mode == 'in') {
      _nameController.text = _predictedName;
      _confirmedExpiryDate = DateTime.now().add(const Duration(days: 5));
    } else {
      // For OUT: match first active item in fridge if available
      final items = ref.read(inventoryNotifierProvider);
      if (items.isNotEmpty) {
        _selectedOutItem = items.first;
        _nameController.text = _selectedOutItem!.name;
      }
    }

    setState(() => _currentStep = ScanStep.reviewPrediction);
  }

  Future<void> _commitOperation() async {
    final notifier = ref.read(inventoryNotifierProvider.notifier);

    if (_mode == 'in') {
      if (_confirmedExpiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify or select the expiration date.')),
        );
        return;
      }

      final newItem = FoodItem(
        id: 'scan-${DateTime.now().microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        category: _predictedCategory,
        storageLocation: _selectedLocation,
        purchaseDate: DateTime.now(),
        expiryDate: _confirmedExpiryDate!,
        quantity: double.tryParse(_qtyController.text) ?? 1.0,
        unit: _unit,
        notes: 'Captured via camera scan workflow (Simulated)',
      );

      await notifier.addItem(newItem);
    } else {
      // OUT mode: deduct quantity
      if (_selectedOutItem != null) {
        final deduct = double.tryParse(_qtyController.text) ?? 1.0;
        await notifier.markConsumed(_selectedOutItem!.id, quantity: deduct);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_mode == 'in'
              ? 'Item successfully logged into fridge!'
              : 'Food deduction logged successfully!'),
          backgroundColor: context.appColors.freshnessSuccess,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == 'in' ? 'Food Intake (IN)' : 'Food Removal (OUT)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Operation indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      _mode == 'in' ? Icons.login_rounded : Icons.logout_rounded,
                      color: _mode == 'in' ? colorScheme.primary : colors.warningAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _mode == 'in'
                            ? 'Adding food: Camera will identify food and ask you to confirm expiry.'
                            : 'Extracting food: Camera will identify items to deduct or finish.',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step B: Camera Preview / Viewfinder
              if (_currentStep == ScanStep.captureImage) ...[
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.cardBorder, width: 2),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 54, color: Colors.white70),
                            const SizedBox(height: 12),
                            Text(
                              'Camera Viewfinder (Mock Preview)',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hold item 20-30 cm away with good lighting',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                        // Corner brackets
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Icon(Icons.crop_free_rounded, size: 36, color: colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Simulate Camera Trigger',
                  icon: Icons.camera_rounded,
                  isFullWidth: true,
                  onPressed: _simulateCapture,
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Switch to Manual Input',
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                  onPressed: () {
                    context.pop();
                    context.push('/food-form');
                  },
                ),
              ],

              // Step C: Processing
              if (_currentStep == ScanStep.processing) ...[
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 24),
                      Text(
                        'Analyzing Food Visuals...',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Extracting classification and packaging characteristics.',
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],

              // Step D & E: Review & Confirm
              if (_currentStep == ScanStep.reviewPrediction) ...[
                // AI prediction badge (Simulated honest indicator)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.smart_toy_outlined, size: 16, color: colors.secondaryAction),
                      const SizedBox(width: 8),
                      Text(
                        'Simulated AI Result (Confidence: 94%)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.secondaryAction),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (_mode == 'in') ...[
                  // Food Name correction
                  AppTextField(
                    label: 'Recognized Item Name (Verify or Edit)',
                    controller: _nameController,
                    prefixIcon: Icons.edit_note_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Quantity and unit
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Quantity',
                          controller: _qtyController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unit',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary),
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
                                  items: ['pcs', 'packs', 'kg', 'g', 'L', 'ml'].map((u) {
                                    return DropdownMenuItem(value: u, child: Text(u));
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _unit = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Explicit Expiry Date Picker (Mandatory)
                  Text(
                    'Expiration Date (Explicit Confirmation Required)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _confirmedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                      );
                      if (picked != null) {
                        setState(() => _confirmedExpiryDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 18, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            _confirmedExpiryDate != null
                                ? DateFormat('EEEE, MMM d, yyyy').format(_confirmedExpiryDate!)
                                : 'Tap to set confirmed expiration date',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // OUT Mode: candidate match from active items
                  Consumer(
                    builder: (context, ref, _) {
                      final items = ref.watch(inventoryNotifierProvider);
                      if (items.isEmpty) {
                        return const Text('No items in fridge to take out.');
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Matched Inventory Item to Deduct:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          ...items.map((item) {
                            final isSelected = _selectedOutItem?.id == item.id;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : colors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? colorScheme.primary : colors.cardBorder,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(item.category.icon, color: colorScheme.primary),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('Available: ${item.quantity} ${item.unit}'),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle_rounded, color: colorScheme.primary)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedOutItem = item;
                                    _nameController.text = item.name;
                                  });
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Amount to Deduct',
                            controller: _qtyController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      );
                    },
                  ),
                ],
                const SizedBox(height: 28),

                AppButton(
                  label: _mode == 'in' ? 'Confirm and Add Item' : 'Confirm Extraction',
                  isFullWidth: true,
                  onPressed: _commitOperation,
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.secondary,
                  isFullWidth: true,
                  onPressed: () => context.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
