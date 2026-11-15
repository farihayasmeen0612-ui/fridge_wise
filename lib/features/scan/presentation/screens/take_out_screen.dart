import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_confirm_dialog.dart';
import '../../../../core/presentation/components/app_image_zoom_dialog.dart';
import '../../../../core/presentation/components/app_status_pill.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../inventory/domain/models/food_item.dart';
import '../../data/pending_requests_provider.dart';
import '../../domain/models/pending_food_request.dart';

/// Dedicated Food Removal (OUT) Review Screen.
/// Displays the photograph captured by the ESP32-S3 camera when the physical OUT button was pressed.
/// Strictly NO Gemini AI is used for Food OUT.
/// The user visually inspects the photograph, selects the removed item(s) from their tracked inventory,
/// and confirms removal to deduct stock.
class TakeOutScreen extends ConsumerStatefulWidget {
  const TakeOutScreen({this.requestId, super.key});

  final String? requestId;

  @override
  ConsumerState<TakeOutScreen> createState() => _TakeOutScreenState();
}

class _TakeOutScreenState extends ConsumerState<TakeOutScreen> {
  PendingFoodRequest? _activeRequest;
  final Map<String, double> _selectedDeductions = {};
  String _searchQuery = '';
  bool _isSubmitting = false;
  bool _isSimulating = false;

  void _syncWithRequest(PendingFoodRequest req) {
    if (_activeRequest?.id == req.id) return;
    _activeRequest = req;
    _selectedDeductions.clear();
  }

  void _toggleItemSelection(FoodItem item) {
    setState(() {
      if (_selectedDeductions.containsKey(item.id)) {
        _selectedDeductions.remove(item.id);
      } else {
        _selectedDeductions[item.id] = 1.0.clamp(1.0, item.quantity);
      }
    });
  }

  void _updateQuantity(FoodItem item, double qty) {
    setState(() {
      _selectedDeductions[item.id] = qty.clamp(1.0, item.quantity);
    });
  }

  Future<void> _handleConfirmTakeOut() async {
    if (_selectedDeductions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item removed from your fridge.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final activeInventory = ref.read(inventoryNotifierProvider);
      final deductions = <FoodDeduction>[];

      for (final entry in _selectedDeductions.entries) {
        final item = activeInventory.where((i) => i.id == entry.key).firstOrNull;
        if (item != null) {
          deductions.add(
            FoodDeduction(
              foodItemId: item.id,
              foodItemName: item.name,
              quantity: entry.value,
              unit: item.unit,
            ),
          );
        }
      }

      if (_activeRequest != null) {
        await ref.read(pendingRequestsProvider.notifier).confirmTakeOut(
              _activeRequest!,
              deductions,
            );
      } else {
        // Manual take-out without hardware request
        final notifier = ref.read(inventoryNotifierProvider.notifier);
        for (final deduction in deductions) {
          await notifier.markConsumed(deduction.foodItemId, quantity: deduction.quantity);
        }
      }

      if (mounted) {
        final itemNames = deductions.map((d) => d.foodItemName).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "$itemNames" from active inventory.'),
            backgroundColor: context.appColors.freshnessSuccess,
          ),
        );

        // Return to the pending removal list screen
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/pending-removals');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm removal: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _handleDismissRequest() async {
    if (_activeRequest == null) return;

    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete Removal Capture',
      message:
          'Are you sure you want to delete this removal capture request? This action cannot be undone.',
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
          const SnackBar(content: Text('Take-out request dismissed.')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/pending-removals');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to dismiss request: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _simulateHardwareOut() async {
    setState(() => _isSimulating = true);
    await Future.delayed(const Duration(milliseconds: 1000));

    final client = supabaseClient;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randHex = timestamp.toRadixString(16).substring(4);
    final filename = 'output_${timestamp}_$randHex.jpg';

    if (client != null) {
      try {
        await client.from(SupabaseConstants.tableInventoryLogs).insert({
          'filename': filename,
          'action_type': 'output',
          'has_food': true,
          'item_count': 1,
          'detected_items': [],
          'notes': 'Physical OUT button capture',
        });
        await ref.read(pendingRequestsProvider.notifier).refresh();
      } catch (e) {
        debugPrint('Simulate takeout error: $e');
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
    final pendingTakeouts = ref.watch(pendingTakeOutRequestsProvider);
    final inventory = ref.watch(inventoryNotifierProvider);

    // Sync active request if specified via route or available in pending list
    if (widget.requestId != null && _activeRequest == null) {
      final match = pendingTakeouts.where((r) => r.id == widget.requestId || r.filename == widget.requestId).firstOrNull;
      if (match != null) _syncWithRequest(match);
    }

    if (_activeRequest == null && pendingTakeouts.isNotEmpty) {
      _syncWithRequest(pendingTakeouts.first);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Removal (OUT)',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: _activeRequest != null
            ? _buildPendingReviewView(colors, colorScheme, pendingTakeouts, inventory)
            : _buildManualOrWaitingView(colors, colorScheme, inventory),
      ),
    );
  }

  Widget _buildPendingReviewView(
    AppColorsExtension colors,
    ColorScheme colorScheme,
    List<PendingFoodRequest> allTakeouts,
    List<FoodItem> inventory,
  ) {
    final req = _activeRequest!;
    final filteredInventory = inventory.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Multi-request selector banner
                if (allTakeouts.length > 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded, size: 16, color: colors.warningAmber),
                        const SizedBox(width: 8),
                        Text(
                          'Pending Take-Out (${allTakeouts.indexOf(req) + 1} of ${allTakeouts.length})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (allTakeouts.indexOf(req) > 0)
                          GestureDetector(
                            onTap: () => setState(() => _syncWithRequest(allTakeouts[allTakeouts.indexOf(req) - 1])),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(Icons.chevron_left_rounded, size: 20, color: colorScheme.primary),
                            ),
                          ),
                        if (allTakeouts.indexOf(req) < allTakeouts.length - 1)
                          GestureDetector(
                            onTap: () => setState(() => _syncWithRequest(allTakeouts[allTakeouts.indexOf(req) + 1])),
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

                // Captured Photograph from ESP32 Camera (tap to zoom full-screen)
                GestureDetector(
                  onTap: req.imageUrl.isNotEmpty
                      ? () => AppImageZoomDialog.show(
                            context,
                            imageUrl: req.imageUrl,
                            title: 'ESP32 OUT Capture',
                          )
                      : null,
                  child: Container(
                    height: 200,
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
                                  Icon(Icons.broken_image_rounded, size: 44, color: colors.textSecondary),
                                  const SizedBox(height: 6),
                                  Text('Photo awaiting CDN propagation', style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          )
                        else
                          Center(child: Icon(Icons.camera_alt_outlined, size: 44, color: colors.textSecondary)),
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
                                  'ESP32 OUT Capture • ${DateFormat('h:mm a').format(req.timestamp.toLocal())}',
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

                // Visual Verification Notice Banner (Explicitly NO AI)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 20, color: colors.secondaryAction),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visual Verification',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Inspect the photo above and select which item(s) you removed below.',
                              style: TextStyle(fontSize: 11, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Filter Field
                AppTextField(
                  label: 'Search Fridge Inventory',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                ),
                const SizedBox(height: 14),

                // Active Inventory Selection List
                Text(
                  'CURRENT FRIDGE INVENTORY (${filteredInventory.length})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                if (filteredInventory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No matching inventory items found.',
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredInventory.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredInventory[index];
                      final isSelected = _selectedDeductions.containsKey(item.id);
                      final selectedQty = _selectedDeductions[item.id] ?? 1.0;

                      return _InventoryDeductionTile(
                        item: item,
                        isSelected: isSelected,
                        selectedQuantity: selectedQty,
                        onToggle: () => _toggleItemSelection(item),
                        onQuantityChanged: (qty) => _updateQuantity(item, qty),
                      );
                    },
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colors.cardBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: _selectedDeductions.isNotEmpty
                    ? 'Confirm Removal (${_selectedDeductions.length} items)'
                    : 'Select Item(s) to Remove',
                icon: Icons.check_circle_rounded,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                isLoading: _isSubmitting,
                onPressed: _selectedDeductions.isNotEmpty ? _handleConfirmTakeOut : null,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Dismiss This Request',
                icon: Icons.close_rounded,
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                onPressed: _isSubmitting ? null : _handleDismissRequest,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualOrWaitingView(
    AppColorsExtension colors,
    ColorScheme colorScheme,
    List<FoodItem> inventory,
  ) {
    final filteredInventory = inventory.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hardware Instructions Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.kitchen_rounded, size: 28, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fridge Camera OUT Ready',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'When taking food out, press the physical OUT button on the fridge. The camera snaps a photo and saves a pending request for your review.',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Simulate Button for Testing
          AppButton(
            label: "Simulate Physical 'OUT' Button Press",
            icon: Icons.sensors_rounded,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
            isLoading: _isSimulating,
            onPressed: _simulateHardwareOut,
          ),
          const SizedBox(height: 20),

          // Manual Take-Out Section
          Text(
            'MANUAL TAKE-OUT FROM ACTIVE INVENTORY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          AppTextField(
            label: 'Search Items to Deduct',
            prefixIcon: Icons.search_rounded,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
          ),
          const SizedBox(height: 12),

          if (filteredInventory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Center(
                child: Text('Your fridge is currently empty.', style: TextStyle(color: colors.textSecondary)),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredInventory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = filteredInventory[index];
                final isSelected = _selectedDeductions.containsKey(item.id);
                final selectedQty = _selectedDeductions[item.id] ?? 1.0;

                return _InventoryDeductionTile(
                  item: item,
                  isSelected: isSelected,
                  selectedQuantity: selectedQty,
                  onToggle: () => _toggleItemSelection(item),
                  onQuantityChanged: (qty) => _updateQuantity(item, qty),
                );
              },
            ),
            const SizedBox(height: 20),
            if (_selectedDeductions.isNotEmpty)
              AppButton(
                label: 'Confirm Manual Removal (${_selectedDeductions.length} items)',
                icon: Icons.check_circle_rounded,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
                isLoading: _isSubmitting,
                onPressed: _handleConfirmTakeOut,
              ),
          ],
        ],
      ),
    );
  }
}

class _InventoryDeductionTile extends StatelessWidget {
  const _InventoryDeductionTile({
    required this.item,
    required this.isSelected,
    required this.selectedQuantity,
    required this.onToggle,
    required this.onQuantityChanged,
  });

  final FoodItem item;
  final bool isSelected;
  final double selectedQuantity;
  final VoidCallback onToggle;
  final ValueChanged<double> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colors.cardBorder,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle(),
                    activeColor: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.unit} available • ${item.storageLocation.label}',
                          style: TextStyle(fontSize: 12, color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AppStatusPill(
                    status: item.expiryStatus,
                    label: item.countdownLabel,
                  ),
                ],
              ),
              if (isSelected) ...[
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text(
                        'Amount to remove:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                        onPressed: selectedQuantity > 1 ? () => onQuantityChanged(selectedQuantity - 1) : null,
                      ),
                      Text(
                        '${selectedQuantity.toInt()} ${item.unit}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorScheme.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                        onPressed: selectedQuantity < item.quantity ? () => onQuantityChanged(selectedQuantity + 1) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
