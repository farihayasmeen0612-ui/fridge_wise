import 'dart:async';
import '../../scan/domain/models/pending_food_request.dart';
import '../domain/models/activity_log_item.dart';
import '../domain/models/expiry_status.dart';
import '../domain/models/food_item.dart';
import '../domain/models/storage_location.dart';
import 'food_repository.dart';

/// In-memory mock implementation of FoodRepository.
/// Enables offline UI development, widget testing, and state verification.
class MockFoodRepository implements FoodRepository {
  MockFoodRepository({bool populateSeedData = false}) {
    _items = populateSeedData ? _generateSeedData() : [];
    _notifyListeners();
  }

  late List<FoodItem> _items;
  final List<ActivityLogItem> _logs = [];
  final List<PendingFoodRequest> _pendingRequests = [];
  final StreamController<List<FoodItem>> _streamController =
      StreamController<List<FoodItem>>.broadcast();
  final StreamController<List<PendingFoodRequest>> _pendingRequestsController =
      StreamController<List<PendingFoodRequest>>.broadcast();

  /// Synchronous snapshot for testing and initial state
  List<FoodItem> get itemsSync => List.unmodifiable(_items);
  List<PendingFoodRequest> get pendingRequestsSync => List.unmodifiable(_pendingRequests);

  void addPendingRequest(PendingFoodRequest req) {
    _pendingRequests.insert(0, req);
    if (!_pendingRequestsController.isClosed) {
      _pendingRequestsController.add(List.unmodifiable(_pendingRequests));
    }
  }

  static List<FoodItem> _generateSeedData() {
    final now = DateTime.now();

    return [
      FoodItem(
        id: 'seed-item-1',
        name: 'Orange Juice',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 9)),
        expiryDate: now.subtract(const Duration(days: 2)),
        quantity: 1.0,
        unit: 'L',
        status: ItemStatus.active,
        notes: 'Carton opened 5 days ago',
      ),
      FoodItem(
        id: 'seed-item-2',
        name: 'Fresh Salmon Fillet',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 2)),
        expiryDate: now,
        quantity: 400.0,
        unit: 'g',
        status: ItemStatus.active,
        notes: 'Cook today for dinner',
      ),
      FoodItem(
        id: 'seed-item-3',
        name: 'Whole Milk',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 5)),
        expiryDate: now.add(const Duration(days: 1)),
        quantity: 1.0,
        unit: 'L',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-4',
        name: 'Organic Baby Spinach',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 3)),
        expiryDate: now.add(const Duration(days: 2)),
        quantity: 250.0,
        unit: 'g',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-5',
        name: 'Artisan Sourdough Loaf',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 3)),
        quantity: 1.0,
        unit: 'pcs',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-6',
        name: 'Greek Plain Yogurt',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 2)),
        expiryDate: now.add(const Duration(days: 7)),
        quantity: 500.0,
        unit: 'g',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-7',
        name: 'Cheddar Cheese Block',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 4)),
        expiryDate: now.add(const Duration(days: 12)),
        quantity: 200.0,
        unit: 'g',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-8',
        name: 'Fuji Apples',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now.subtract(const Duration(days: 1)),
        expiryDate: now.add(const Duration(days: 14)),
        quantity: 6.0,
        unit: 'pcs',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-9',
        name: 'Frozen Mixed Berries',
        storageLocation: StorageLocation.freezer,
        purchaseDate: now.subtract(const Duration(days: 10)),
        expiryDate: now.add(const Duration(days: 60)),
        quantity: 1.0,
        unit: 'kg',
        status: ItemStatus.active,
      ),
      FoodItem(
        id: 'seed-item-10',
        name: 'Vanilla Bean Ice Cream',
        storageLocation: StorageLocation.deepFridge,
        purchaseDate: now.subtract(const Duration(days: 15)),
        expiryDate: now.add(const Duration(days: 120)),
        quantity: 1.0,
        unit: 'tub',
        status: ItemStatus.active,
      ),
    ];
  }

  void _notifyListeners() {
    _streamController.add(List.unmodifiable(_items));
  }

  @override
  Future<List<FoodItem>> getItems({
    StorageLocation? location,
    ItemStatus? status = ItemStatus.active,
  }) async {
    return _items.where((item) {
      if (location != null && item.storageLocation != location) return false;
      if (status != null && item.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Stream<List<FoodItem>> watchItems({
    StorageLocation? location,
    ItemStatus? status = ItemStatus.active,
  }) {
    return _streamController.stream.map((list) {
      return list.where((item) {
        if (location != null && item.storageLocation != location) return false;
        if (status != null && item.status != status) return false;
        return true;
      }).toList();
    });
  }

  @override
  Future<FoodItem?> getItemById(String id) async {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addItem(FoodItem item) async {
    _items.add(item);
    _logs.add(
      ActivityLogItem(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        actionType: LogActionType.added,
        itemName: item.name,
        quantity: item.quantity,
        unit: item.unit,
        timestamp: DateTime.now(),
      ),
    );
    _notifyListeners();
  }

  @override
  Future<void> updateItem(FoodItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _logs.add(
        ActivityLogItem(
          id: 'log-${DateTime.now().microsecondsSinceEpoch}',
          actionType: LogActionType.updated,
          itemName: item.name,
          quantity: item.quantity,
          unit: item.unit,
          timestamp: DateTime.now(),
        ),
      );
      _notifyListeners();
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    final item = await getItemById(id);
    if (item != null) {
      _items.removeWhere((i) => i.id == id);
      _notifyListeners();
    }
  }

  @override
  Future<void> markConsumed(String id, {double? quantity}) async {
    final item = await getItemById(id);
    if (item != null) {
      final deductAmount = quantity ?? item.quantity;
      final remaining = item.quantity - deductAmount;

      if (remaining <= 0) {
        final updated = item.copyWith(
          quantity: 0,
          status: ItemStatus.consumed,
        );
        await updateItem(updated);
      } else {
        final updated = item.copyWith(quantity: remaining);
        await updateItem(updated);
      }

      _logs.add(
        ActivityLogItem(
          id: 'log-${DateTime.now().microsecondsSinceEpoch}',
          actionType: LogActionType.consumed,
          itemName: item.name,
          quantity: deductAmount,
          unit: item.unit,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> markDiscarded(String id) async {
    final item = await getItemById(id);
    if (item != null) {
      final updated = item.copyWith(status: ItemStatus.discarded);
      await updateItem(updated);

      _logs.add(
        ActivityLogItem(
          id: 'log-${DateTime.now().microsecondsSinceEpoch}',
          actionType: LogActionType.discarded,
          itemName: item.name,
          quantity: item.quantity,
          unit: item.unit,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<List<ActivityLogItem>> getActivityLogs() async {
    return List.unmodifiable(_logs);
  }

  @override
  Future<List<PendingFoodRequest>> getPendingRequests() async {
    return List.unmodifiable(_pendingRequests);
  }

  @override
  Stream<List<PendingFoodRequest>> watchPendingRequests() {
    return _pendingRequestsController.stream;
  }

  @override
  Future<void> confirmIntake(PendingFoodRequest request, FoodItem confirmedItem) async {
    await addItem(confirmedItem);
    _pendingRequests.removeWhere((r) => r.id == request.id);
    if (!_pendingRequestsController.isClosed) {
      _pendingRequestsController.add(List.unmodifiable(_pendingRequests));
    }
  }

  @override
  Future<void> confirmTakeOut(PendingFoodRequest request, List<FoodDeduction> deductions) async {
    for (final deduction in deductions) {
      await markConsumed(deduction.foodItemId, quantity: deduction.quantity);
    }
    _pendingRequests.removeWhere((r) => r.id == request.id);
    if (!_pendingRequestsController.isClosed) {
      _pendingRequestsController.add(List.unmodifiable(_pendingRequests));
    }
  }

  @override
  Future<void> dismissPendingRequest(String requestId, String filename) async {
    _pendingRequests.removeWhere((r) => r.id == requestId || r.filename == filename);
    if (!_pendingRequestsController.isClosed) {
      _pendingRequestsController.add(List.unmodifiable(_pendingRequests));
    }
  }

  void dispose() {
    _streamController.close();
    _pendingRequestsController.close();
  }
}
