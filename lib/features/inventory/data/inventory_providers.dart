import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_provider.dart';
import '../../dashboard/domain/models/inventory_summary.dart';
import '../domain/models/activity_log_item.dart';
import '../domain/models/expiry_status.dart';
import '../domain/models/food_item.dart';
import 'food_repository.dart';
import 'mock_food_repository.dart';
import 'supabase_food_repository.dart';

/// Provider for the abstract FoodRepository (defaults to SupabaseFoodRepository with offline fallback)
final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  final auth = ref.watch(authProvider);
  final repository = SupabaseFoodRepository(userId: auth.isAuthenticated ? auth.uid : null);
  ref.onDispose(repository.dispose);
  return repository;
});

/// Riverpod Notifier providing reactive management of active food items.
class InventoryNotifier extends Notifier<List<FoodItem>> {
  @override
  List<FoodItem> build() {
    final repository = ref.watch(foodRepositoryProvider);
    if (repository is MockFoodRepository) {
      return repository.itemsSync;
    }
    
    // Listen to real-time stream updates from Supabase Realtime
    final subscription = repository.watchItems().listen((items) {
      state = items;
    });
    ref.onDispose(subscription.cancel);

    _loadItems(repository);
    return const [];
  }

  Future<void> _loadItems(FoodRepository repository) async {
    final items = await repository.getItems();
    state = items;
  }

  Future<void> addItem(FoodItem item) async {
    final repository = ref.read(foodRepositoryProvider);
    await repository.addItem(item);
    state = await repository.getItems();
  }

  Future<void> updateItem(FoodItem item) async {
    final repository = ref.read(foodRepositoryProvider);
    await repository.updateItem(item);
    state = await repository.getItems();
  }

  Future<void> deleteItem(String id) async {
    final repository = ref.read(foodRepositoryProvider);
    await repository.deleteItem(id);
    state = await repository.getItems();
  }

  Future<void> markConsumed(String id, {double? quantity}) async {
    final repository = ref.read(foodRepositoryProvider);
    await repository.markConsumed(id, quantity: quantity);
    state = await repository.getItems();
  }

  Future<void> markDiscarded(String id) async {
    final repository = ref.read(foodRepositoryProvider);
    await repository.markDiscarded(id);
    state = await repository.getItems();
  }
}

/// Provider exposing the reactive inventory item list
final inventoryNotifierProvider =
    NotifierProvider<InventoryNotifier, List<FoodItem>>(
  InventoryNotifier.new,
);

/// Derived provider computing the aggregated InventorySummary for the Dashboard
final inventorySummaryProvider = Provider<InventorySummary>((ref) {
  final items = ref.watch(inventoryNotifierProvider);
  return InventorySummary.fromItems(items);
});

/// Derived provider returning urgent items (expired or expiring soon), sorted by expiry date
final urgentItemsProvider = Provider<List<FoodItem>>((ref) {
  final items = ref.watch(inventoryNotifierProvider);
  final urgent = items
      .where((item) =>
          item.status == ItemStatus.active &&
          (item.isExpired || item.isExpiringSoon))
      .toList();
  urgent.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
  return urgent;
});

/// Provider returning recent activity logs and camera scans from food_inventory_logs
final activityLogsProvider = FutureProvider<List<ActivityLogItem>>((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return repository.getActivityLogs();
});
