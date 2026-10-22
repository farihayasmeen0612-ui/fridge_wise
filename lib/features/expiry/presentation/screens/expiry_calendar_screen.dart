import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/components/app_empty_state.dart';
import '../../../../core/presentation/components/app_food_row.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../../inventory/data/inventory_providers.dart';
import '../../../inventory/domain/models/food_item.dart';
import '../../../inventory/domain/utils/expiry_calculator.dart';

class ExpiryCalendarScreen extends ConsumerStatefulWidget {
  const ExpiryCalendarScreen({super.key});

  @override
  ConsumerState<ExpiryCalendarScreen> createState() => _ExpiryCalendarScreenState();
}

class _ExpiryCalendarScreenState extends ConsumerState<ExpiryCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + offset, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;
    final items = ref.watch(inventoryNotifierProvider);

    // Group items by calendar day
    final Map<String, List<FoodItem>> itemsByDate = {};
    for (final item in items) {
      final key = DateFormat('yyyy-MM-dd').format(item.expiryDate);
      itemsByDate.putIfAbsent(key, () => []).add(item);
    }

    final selectedKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final selectedDayItems = itemsByDate[selectedKey] ?? [];

    // All upcoming items in the next 14 days sorted by urgency
    final upcomingItems = items.where((i) {
      final diff = ExpiryCalculator.calculateDaysRemaining(i.expiryDate);
      return diff >= 0 && diff <= 14;
    }).toList()
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expiry Calendar & Agenda',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Calendar Card
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Month Navigator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_displayedMonth),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Days of week header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                        return SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),

                    // Calendar Grid
                    _buildCalendarGrid(itemsByDate),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Selected Date Agenda Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(_selectedDate).toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${selectedDayItems.length} expiring',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (selectedDayItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Center(
                    child: Text(
                      'No tracked items expire on this day.',
                      style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedDayItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = selectedDayItems[index];
                    return AppFoodRow(
                      item: item,
                      onTap: () => context.push('/food-details/${item.id}'),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Upcoming 14 Days Urgency Section
              Text(
                'UPCOMING SHELF-LIFE TIMELINE (14 DAYS)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              if (upcomingItems.isEmpty)
                const AppEmptyState(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'No Imminent Expiries',
                  description: 'All food items have extensive shelf-life remaining.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcomingItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = upcomingItems[index];
                    return AppFoodRow(
                      item: item,
                      onTap: () => context.push('/food-details/${item.id}'),
                    );
                  },
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, List<FoodItem>> itemsByDate) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    final totalCells = startWeekday + daysInMonth;
    final totalRows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(totalRows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - startWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox(width: 36, height: 40);
              }

              final cellDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
              final dateKey = DateFormat('yyyy-MM-dd').format(cellDate);
              final isSelected = DateFormat('yyyy-MM-dd').format(_selectedDate) == dateKey;
              final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
              final expiringItems = itemsByDate[dateKey] ?? [];

              Color dotColor = Colors.transparent;
              if (expiringItems.any((i) => i.isExpired)) {
                dotColor = colors.dangerRed;
              } else if (expiringItems.any((i) => i.isExpiringSoon)) {
                dotColor = colors.warningAmber;
              } else if (expiringItems.isNotEmpty) {
                dotColor = colors.freshnessSuccess;
              }

              return InkWell(
                onTap: () => setState(() => _selectedDate = cellDate),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(color: colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.onPrimary : dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
