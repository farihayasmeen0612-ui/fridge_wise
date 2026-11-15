import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../inventory/domain/models/food_item.dart';

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
  ScanStep _currentStep = ScanStep.captureImage;

  // Recognized / Edit State (for OUT mode)
  FoodItem? _selectedOutItem; // For OUT mode: existing item in fridge

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode.toLowerCase() == 'out' ? 'out' : 'in';
    if (_mode == 'out') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pushReplacement('/take-out');
      });
    }
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

    // For OUT: match first active item in fridge if available
    final items = ref.read(inventoryNotifierProvider);
    if (items.isNotEmpty) {
      _selectedOutItem = items.first;
      _nameController.text = _selectedOutItem!.name;
    }

    setState(() => _currentStep = ScanStep.reviewPrediction);
  }

  Future<void> _commitOperation() async {
    final notifier = ref.read(inventoryNotifierProvider.notifier);

    // OUT mode: deduct quantity
    if (_selectedOutItem != null) {
      final deduct = double.tryParse(_qtyController.text) ?? 1.0;
      await notifier.markConsumed(_selectedOutItem!.id, quantity: deduct);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Food deduction logged successfully!'),
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
              // ========================================================
              // IN MODE: EXACTLY TWO OPTIONS (Scan Camera vs Manual)
              // ========================================================
              if (_mode == 'in') ...[
                // Operation header banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.login_rounded, color: colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Intake Method',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Log newly purchased items into your fridge inventory.',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Option 1: Scan with Fridge Camera (Primary IoT method)
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/fridge-camera'),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.camera_enhance_rounded, color: colorScheme.primary, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Scan with Fridge Camera',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colors.freshnessSuccess.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'PRIMARY IOT METHOD • ESP32-S3 CAM',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: colors.freshnessSuccess,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colors.textSecondary),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Automatically detect produce via the camera mounted inside your fridge.\n'
                              'Press the physical IN button on your fridge to capture food.',
                              style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: 'Scan with Fridge Camera',
                              icon: Icons.camera_alt_rounded,
                              isFullWidth: true,
                              onPressed: () => context.push('/fridge-camera'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Option 2: Enter Manually (Preserves existing workflow completely)
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push('/food-form'),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.cardBorder),
                                  ),
                                  child: Icon(Icons.edit_note_rounded, color: colorScheme.onSurface, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Enter Manually',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Standard manual entry workflow',
                                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colors.textSecondary),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Type item name, category, quantity, storage location, and set confirmed expiration date.',
                              style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              label: 'Enter Manually',
                              variant: AppButtonVariant.secondary,
                              icon: Icons.edit_rounded,
                              isFullWidth: true,
                              onPressed: () => context.push('/food-form'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // ========================================================
                // OUT MODE: REMAINING WORKFLOW (Untouched Extraction Flow)
                // ========================================================
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
                        Icons.logout_rounded,
                        color: colors.warningAmber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Extracting food: Camera will identify items to deduct or finish.',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

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
                            children: const [
                              Icon(Icons.camera_alt_outlined, size: 54, color: Colors.white70),
                              SizedBox(height: 12),
                              Text(
                                'Camera Viewfinder (Mock Preview)',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Hold item 20-30 cm away with good lighting',
                                style: TextStyle(color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
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
                ],

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
                          'Matching items in fridge to deduct.',
                          style: TextStyle(fontSize: 13, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_currentStep == ScanStep.reviewPrediction) ...[
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
                                leading: Icon(item.storageLocation.icon, color: colorScheme.primary),
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
                  const SizedBox(height: 28),
                  AppButton(
                    label: 'Confirm Extraction',
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
            ],
          ),
        ),
      ),
    );
  }
}
