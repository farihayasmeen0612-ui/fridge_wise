import '../domain/models/activity_log_item.dart';
import '../domain/models/food_category.dart';
import '../domain/models/food_item.dart';
import '../domain/models/expiry_status.dart';
import '../domain/models/storage_location.dart';

/// Abstract contract for food inventory data management.
/// Followed by both MockFoodRepository and future FirestoreFoodRepository.
abstract class FoodRepository {
  /// Fetches a snapshot of items with optional filters
  Future<List<FoodItem>> getItems({
    StorageLocation? location,
    FoodCategory? category,
    ItemStatus? status,
  });

  /// Streams real-time updates of items with optional filters
  Stream<List<FoodItem>> watchItems({
    StorageLocation? location,
    FoodCategory? category,
    ItemStatus? status,
  });

  /// Retrieves a specific item by its unique identifier
  Future<FoodItem?> getItemById(String id);

  /// Adds a new food item to inventory
  Future<void> addItem(FoodItem item);

  /// Updates an existing food item
  Future<void> updateItem(FoodItem item);

  /// Permanently removes an item from inventory
  Future<void> deleteItem(String id);

  /// Deducts quantity or transitions item to consumed status
  Future<void> markConsumed(String id, {double? quantity});

  /// Marks item as discarded/spoiled for waste tracking
  Future<void> markDiscarded(String id);

  /// Fetches historical activity/audit logs
  Future<List<ActivityLogItem>> getActivityLogs();
}
