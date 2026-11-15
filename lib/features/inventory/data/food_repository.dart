import '../../scan/domain/models/pending_food_request.dart';
import '../domain/models/activity_log_item.dart';
import '../domain/models/expiry_status.dart';
import '../domain/models/food_item.dart';
import '../domain/models/storage_location.dart';

/// Abstract contract for food inventory and pending hardware requests data management.
abstract class FoodRepository {
  /// Fetches a snapshot of items with optional filters
  Future<List<FoodItem>> getItems({
    StorageLocation? location,
    ItemStatus? status,
  });

  /// Streams real-time updates of items with optional filters
  Stream<List<FoodItem>> watchItems({
    StorageLocation? location,
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

  /// Fetches unconfirmed pending intake and takeout requests captured by ESP32-S3
  Future<List<PendingFoodRequest>> getPendingRequests();

  /// Streams real-time updates of unconfirmed pending requests
  Stream<List<PendingFoodRequest>> watchPendingRequests();

  /// Confirms a pending intake request, saving the confirmed item to active inventory
  Future<void> confirmIntake(PendingFoodRequest request, FoodItem confirmedItem);

  /// Confirms a pending takeout request, deducting the chosen food items from inventory
  Future<void> confirmTakeOut(PendingFoodRequest request, List<FoodDeduction> deductions);

  /// Dismisses an unconfirmed request without deleting it from the database
  Future<void> dismissPendingRequest(String requestId, String filename);
}
