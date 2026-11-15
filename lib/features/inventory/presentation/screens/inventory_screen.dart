import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_empty_state.dart';
import '../../../../core/presentation/components/app_food_row.dart';
import '../../../../core/presentation/components/app_search_bar.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../domain/models/expiry_status.dart';
import '../../domain/models/storage_location.dart';
import '../../data/inventory_providers.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  StorageLocation? _selectedLocation; // null = All
  ExpiryStatus? _selectedStatusFilter; // null = All

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final allItems = ref.watch(inventoryNotifierProvider);

    // Apply Filters & Search
    final filteredItems = allItems.where((item) {
      if (item.status != ItemStatus.active) return false;
      if (_selectedLocation != null && item.storageLocation != _selectedLocation) {
        return false;
      }
      if (_selectedStatusFilter != null && item.expiryStatus != _selectedStatusFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();

    // Sort: Urgent first
    filteredItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Fridge Inventory',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              '${filteredItems.length} of ${allItems.where((i) => i.status == ItemStatus.active).length} items',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/food-form'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Food', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: AppSearchBar(
                controller: _searchController,
                hintText: 'Search food by name...',
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                onClear: () => setState(() => _searchQuery = ''),
              ),
            ),

            // Storage Zone Chips (All, Fridge, Freezer, Pantry)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _StorageFilterChip(
                    label: 'All Zones',
                    isSelected: _selectedLocation == null,
                    onTap: () => setState(() => _selectedLocation = null),
                  ),
                  const SizedBox(width: 8),
                  ...StorageLocation.values.map((loc) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _StorageFilterChip(
                        label: loc.label,
                        isSelected: _selectedLocation == loc,
                        onTap: () => setState(() => _selectedLocation = _selectedLocation == loc ? null : loc),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Status Filter Strip (All, Expiring Soon, Expired, Fresh)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _StatusTagChip(
                    label: 'All Status',
                    isSelected: _selectedStatusFilter == null,
                    color: colorScheme.onSurface,
                    onTap: () => setState(() => _selectedStatusFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _StatusTagChip(
                    label: 'Expiring Soon',
                    isSelected: _selectedStatusFilter == ExpiryStatus.expiringSoon,
                    color: colors.warningAmber,
                    onTap: () => setState(() => _selectedStatusFilter =
                        _selectedStatusFilter == ExpiryStatus.expiringSoon ? null : ExpiryStatus.expiringSoon),
                  ),
                  const SizedBox(width: 8),
                  _StatusTagChip(
                    label: 'Expired',
                    isSelected: _selectedStatusFilter == ExpiryStatus.expired,
                    color: colors.dangerRed,
                    onTap: () => setState(() => _selectedStatusFilter =
                        _selectedStatusFilter == ExpiryStatus.expired ? null : ExpiryStatus.expired),
                  ),
                  const SizedBox(width: 8),
                  _StatusTagChip(
                    label: 'Fresh',
                    isSelected: _selectedStatusFilter == ExpiryStatus.fresh,
                    color: colors.freshnessSuccess,
                    onTap: () => setState(() => _selectedStatusFilter =
                        _selectedStatusFilter == ExpiryStatus.fresh ? null : ExpiryStatus.fresh),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Divider(height: 1, color: colors.cardBorder),

            // Food List / Empty States
            Expanded(
              child: filteredItems.isEmpty
                  ? (_searchQuery.isNotEmpty || _selectedLocation != null || _selectedStatusFilter != null)
                      ? AppEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No Matching Items Found',
                          description: 'Try adjusting your search query, status, or storage filters.',
                          actionLabel: 'Reset All Filters',
                          onAction: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _selectedLocation = null;
                              _selectedStatusFilter = null;
                            });
                          },
                        )
                      : AppEmptyState(
                          icon: Icons.kitchen_rounded,
                          title: 'Your Fridge is Empty',
                          description: 'Add your groceries manually or capture with camera to begin tracking shelf-life.',
                          actionLabel: 'Add Your First Item',
                          onAction: () => context.push('/food-form'),
                        )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return AppFoodRow(
                          item: item,
                          onTap: () => context.push('/food-details/${item.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageFilterChip extends StatelessWidget {
  const _StorageFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primary : colors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colors.cardBorder,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTagChip extends StatelessWidget {
  const _StatusTagChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isSelected ? color : colors.cardBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? color : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
