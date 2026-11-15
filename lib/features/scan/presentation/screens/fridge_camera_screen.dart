import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/presentation/components/app_image_zoom_dialog.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../inventory/domain/models/food_item.dart';
import '../../../inventory/domain/models/storage_location.dart';
import '../../data/pending_requests_provider.dart';
import '../../domain/models/pending_food_request.dart';

/// Dedicated Food Intake (IN) Review Screen.
/// Supports both asynchronous review of pending ESP32-S3 intakes identified by Gemini AI
/// and direct real-time capture when physical buttons are pressed.
class FridgeCameraScreen extends ConsumerStatefulWidget {
  const FridgeCameraScreen({this.requestId, super.key});

  final String? requestId;

  @override
  ConsumerState<FridgeCameraScreen> createState() => _FridgeCameraScreenState();
}

class _FridgeCameraScreenState extends ConsumerState<FridgeCameraScreen> {
  PendingFoodRequest? _activeRequest;
  String _selectedUnit = 'pcs';
  StorageLocation _selectedLocation = StorageLocation.refrigerator;
  DateTime? _confirmedExpiryDate;

  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1.0');

  bool _isSubmitting = false;
  bool _isSimulating = false;

  final List<String> _commonUnits = ['pcs', 'kg', 'g', 'L', 'ml', 'packs', 'bottles'];

  @override
  void initState() {
    super.initState();
    _confirmedExpiryDate = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _syncWithRequest(PendingFoodRequest req) {
    if (_activeRequest?.id == req.id) return;

    _activeRequest = req;
    final bool hasDetectedFood =
        req.hasFood && (req.aiDetectedName != null && req.aiDetectedName!.trim().isNotEmpty);
    _nameController.text = hasDetectedFood ? req.aiDetectedName! : '';
    _qtyController.text = '1.0';
    _selectedLocation = StorageLocation.refrigerator;
    _selectedUnit = 'pcs';

    // Estimate initial shelf-life based on Gemini's predicted category
    int shelfDays = 7;
    final cat = (req.aiCategory ?? '').toLowerCase();
    if (cat.contains('meat') || cat.contains('seafood') || cat.contains('fish')) {
      shelfDays = 3;
    } else if (cat.contains('dairy') || cat.contains('milk') || cat.contains('curd')) {
      shelfDays = 5;
    } else if (cat.contains('fruit') || cat.contains('produce') || cat.contains('vegetable')) {
      shelfDays = 7;
    } else if (cat.contains('condiment') || cat.contains('sauce') || cat.contains('pickle')) {
      shelfDays = 30;
    }
    _confirmedExpiryDate = req.timestamp.add(Duration(days: shelfDays));
  }

  Future<void> _handleConfirmIntake() async {
    final foodName = _nameController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid food name.')),
      );
      return;
    }

    final qty = double.tryParse(_qtyController.text) ?? 1.0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than zero.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final confirmedItem = FoodItem(
        id: 'food_${DateTime.now().millisecondsSinceEpoch}',
        name: foodName,
        storageLocation: _selectedLocation,
        purchaseDate: _activeRequest?.timestamp ?? DateTime.now(),
        expiryDate: _confirmedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
        quantity: qty,
        unit: _selectedUnit,
        notes: _activeRequest?.aiCategory != null && _activeRequest!.aiCategory!.isNotEmpty
            ? 'Category: ${_activeRequest!.aiCategory}'
            : null,
        imageUrl: _activeRequest?.imageUrl,
      );

      if (_activeRequest != null) {
        await ref.read(pendingRequestsProvider.notifier).confirmIntake(
              _activeRequest!,
              confirmedItem,
            );
      } else {
        await ref.read(inventoryNotifierProvider.notifier).addItem(confirmedItem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${confirmedItem.name}" entered into active inventory!'),
            backgroundColor: context.appColors.freshnessSuccess,
          ),
        );

        // Return to the pending intake list screen
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/pending-intakes');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving food item: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDismissRequest() async {
    if (_activeRequest == null) return;

    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Capture',
      message:
          'Are you sure you want to delete this photo capture request? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true) return;

    final req = _activeRequest!;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(pendingRequestsProvider.notifier).dismiss(req);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Capture deleted.')),
        );
        // Return to the pending intake list screen
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/pending-intakes');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete request: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _simulateHardwareIntake() async {
    setState(() => _isSimulating = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    final client = supabaseClient;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randHex = timestamp.toRadixString(16).substring(4);
    final filename = 'input_${timestamp}_$randHex.jpg';

    if (client != null) {
      try {
        await client.from(SupabaseConstants.tableInventoryLogs).insert({
          'filename': filename,
          'action_type': 'input',
          'has_food': true,
          'item_count': 1,
          'detected_items': [
            {'name': 'Green Chili', 'category': 'Vegetable'}
          ],
          'notes': '[gemini-3.5-flash] Bench simulation intake',
        });
        await ref.read(pendingRequestsProvider.notifier).refresh();
      } catch (e) {
        debugPrint('Simulate intake error: $e');
      }
    }

    if (mounted) {
      setState(() => _isSimulating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final pendingIntakes = ref.watch(pendingIntakeRequestsProvider);

    // Synchronize active request with selected or available requests
    if (widget.requestId != null && _activeRequest == null) {
      final match = pendingIntakes.where((r) => r.id == widget.requestId || r.filename == widget.requestId).firstOrNull;
      if (match != null) _syncWithRequest(match);
    }

    if (_activeRequest == null && pendingIntakes.isNotEmpty) {
      _syncWithRequest(pendingIntakes.first);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Intake (IN)',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _activeRequest != null
            ? _buildReviewContent(colors, colorScheme, pendingIntakes)
            : _buildEmptyWaitingState(colors, colorScheme),
      ),
    );
  }

  Widget _buildReviewContent(
    AppColorsExtension colors,
    ColorScheme colorScheme,
    List<PendingFoodRequest> allIntakes,
  ) {
    final req = _activeRequest!;
    final bool isFoodDetected =
        req.hasFood && (req.aiDetectedName != null && req.aiDetectedName!.trim().isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Multi-request selector banner (if user has > 1 pending intake)
          if (allIntakes.length > 1) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Pending Intake (${allIntakes.indexOf(req) + 1} of ${allIntakes.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (allIntakes.indexOf(req) > 0)
                    GestureDetector(
                      onTap: () => setState(() => _syncWithRequest(allIntakes[allIntakes.indexOf(req) - 1])),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.chevron_left_rounded, size: 20, color: colorScheme.primary),
                      ),
                    ),
                  if (allIntakes.indexOf(req) < allIntakes.length - 1)
                    GestureDetector(
                      onTap: () => setState(() => _syncWithRequest(allIntakes[allIntakes.indexOf(req) + 1])),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Captured Photograph Container (tap to zoom full-screen)
          GestureDetector(
            onTap: req.imageUrl.isNotEmpty
                ? () => AppImageZoomDialog.show(
                      context,
                      imageUrl: req.imageUrl,
                      title: req.aiDetectedName ?? 'ESP32 IN Capture',
                    )
                : null,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (req.imageUrl.isNotEmpty)
                    Image.network(
                      req.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_rounded, size: 48, color: colors.textSecondary),
                            const SizedBox(height: 8),
                            Text('Photo awaiting CDN propagation', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                    )
                  else
                    Center(
                      child: Icon(Icons.camera_alt_outlined, size: 48, color: colors.textSecondary),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text(
                            'ESP32 IN Capture • ${DateFormat('h:mm a').format(req.timestamp.toLocal())}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Gemini AI Identification Notice Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isFoodDetected
                  ? colors.surfaceElevated
                  : colors.warningContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isFoodDetected
                    ? colorScheme.primary.withValues(alpha: 0.35)
                    : colors.warningAmber.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isFoodDetected
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colors.warningContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isFoodDetected ? Icons.auto_awesome_rounded : Icons.warning_amber_rounded,
                    color: isFoodDetected ? colorScheme.primary : colors.warningAmber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isFoodDetected ? req.aiDetectedName! : 'No Food Detected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isFoodDetected && req.aiCategory != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.freshnessContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                req.aiCategory!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: colors.freshnessSuccess,
                                ),
                              ),
                            )
                          else if (!isFoodDetected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.warningContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ALERT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: colors.warningAmber,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isFoodDetected
                            ? 'Confirm details below to add this item to active inventory.'
                            : 'Delete this capture with the trash icon or manually enter a food name below to track it.',
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Editable Food Name Field
          AppTextField(
            label: isFoodDetected
                ? 'Food Item Name (Edit if needed)'
                : 'Food Item Name (Enter manually)',
            hintText: 'e.g. Milk, Apples, Bread',
            controller: _nameController,
            prefixIcon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 14),

          // Quantity & Unit Fields
          Row(
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  label: 'Quantity',
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.format_list_numbered_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    filled: true,
                    fillColor: colors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.cardBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: _commonUnits.map((u) {
                    return DropdownMenuItem(value: u, child: Text(u));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedUnit = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Storage Location Selector (Fridge vs Freezer)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STORAGE COMPARTMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: StorageLocation.values.map((loc) {
                  final isSelected = _selectedLocation == loc;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: _LocationOptionCard(
                        icon: loc.icon,
                        title: loc.label,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedLocation = loc),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expiry Date Picker Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 20, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimated Expiration Date',
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                      Text(
                        _confirmedExpiryDate != null
                            ? DateFormat('EEEE, MMM d, yyyy').format(_confirmedExpiryDate!)
                            : 'Select Date',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _confirmedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _confirmedExpiryDate = picked);
                    }
                  },
                  child: const Text('Change Date'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Action CTA
          AppButton(
            label: 'Confirm & Add to Inventory',
            icon: Icons.check_circle_rounded,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: _isSubmitting,
            onPressed: _handleConfirmIntake,
          ),
          const SizedBox(height: 10),

          // Dismiss / Delete Button
          AppButton(
            label: isFoodDetected ? 'Dismiss This Request' : 'Delete Capture',
            icon: isFoodDetected ? Icons.close_rounded : Icons.delete_outline_rounded,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            onPressed: _isSubmitting ? null : _handleDismissRequest,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyWaitingState(AppColorsExtension colors, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.camera_indoor_rounded, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Fridge Camera Intake Ready',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Place food inside the fridge and press the physical IN button on the ESP32-S3 camera hub.\n\n'
            'The camera will photograph your food, Gemini AI will identify it, and you will receive a notification to review and confirm whenever convenient.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Hardware Simulation Trigger (For Testing & Bench Mock Mode)
          AppButton(
            label: "Simulate Physical 'IN' Button Press",
            icon: Icons.sensors_rounded,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            isLoading: _isSimulating,
            onPressed: _simulateHardwareIntake,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Enter Food Manually',
            icon: Icons.edit_note_rounded,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            onPressed: () => context.push('/food-form'),
          ),
        ],
      ),
    );
  }
}

class _LocationOptionCard extends StatelessWidget {
  const _LocationOptionCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary.withValues(alpha: 0.12) : colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colors.cardBorder,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? colorScheme.primary : colors.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
