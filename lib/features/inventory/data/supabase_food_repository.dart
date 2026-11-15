import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../scan/domain/models/pending_food_request.dart';
import '../domain/models/activity_log_item.dart';
import '../domain/models/expiry_status.dart';
import '../domain/models/food_item.dart';
import '../domain/models/storage_location.dart';
import 'food_repository.dart';

class _StockAgg {
  _StockAgg({
    required this.name,
    required this.quantity,
    this.category,
    this.storageLocation = StorageLocation.refrigerator,
    required this.lastUpdated,
    this.photoFilename,
    this.expiryDate,
    this.purchaseDate,
    this.unit = 'pcs',
    this.notes,
  });

  String name;
  double quantity;
  String? category;
  StorageLocation storageLocation;
  DateTime lastUpdated;
  String? photoFilename;
  DateTime? expiryDate;
  DateTime? purchaseDate;
  String unit;
  String? notes;
}

/// Production Supabase-backed implementation of FoodRepository.
///
/// Directly integrates with:
/// - TABLE `food_inventory_logs`: append-only audit trail from ESP32 & Mobile app
/// - BUCKET `Photos`: public CDN storage for captured camera pictures
/// - REALTIME WEBSOCKET: automatic UI refreshes via `postgres_changes` + polling fallback
/// - ASYNCHRONOUS WORKFLOW: Raw hardware captures (`input_*.jpg`, `output_*.jpg`) remain
///   unconfirmed pending requests until the user explicitly reviews & confirms them.
class SupabaseFoodRepository implements FoodRepository {
  SupabaseFoodRepository({this.userId}) {
    _loadLocalOverrides();
    _initRealtimeSubscription();
  }

  final String? userId;

  static const String primaryOwnerUid = '1cfe4919-fe51-461a-8058-48976ad1dd1d';

  String get _overridePrefsKey =>
      userId != null && userId!.isNotEmpty ? 'saved_food_item_edits_$userId' : 'saved_food_item_edits_guest';

  String get _activeUserId =>
      userId ?? supabaseClient?.auth.currentUser?.id ?? '';

  bool _isItemOwnedByCurrentUser(String? itemUserId) {
    if (_activeUserId.isEmpty) return true;
    if (itemUserId != null && itemUserId.isNotEmpty) {
      return itemUserId == _activeUserId;
    }
    return _activeUserId == primaryOwnerUid;
  }

  String? _extractUserIdFromRow(Map<String, dynamic> r) {
    final detected = r['detected_items'] as List<dynamic>?;
    if (detected != null && detected.isNotEmpty) {
      for (final it in detected) {
        if (it is Map && it['user_id'] != null) {
          return it['user_id'].toString();
        }
      }
    }
    final notes = r['notes'] as String? ?? '';
    final match = RegExp(r'\[uid:([^\]]+)\]').firstMatch(notes);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  final StreamController<List<FoodItem>> _streamController =
      StreamController<List<FoodItem>>.broadcast();

  final StreamController<List<PendingFoodRequest>> _pendingRequestsController =
      StreamController<List<PendingFoodRequest>>.broadcast();

  RealtimeChannel? _realtimeChannel;
  Timer? _pollingTimer;
  List<FoodItem> _cachedItems = [];
  List<PendingFoodRequest> _cachedPendingRequests = [];
  final Map<String, FoodItem> _itemOverrides = {};

  Future<void> _loadLocalOverrides() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_overridePrefsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        _itemOverrides.clear();
        for (final entry in decoded.entries) {
          if (entry.value is Map<String, dynamic>) {
            _itemOverrides[entry.key] = FoodItem.fromMap(entry.value as Map<String, dynamic>);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading local food overrides: $e');
    }
  }

  Future<void> _saveLocalOverride(FoodItem item) async {
    _itemOverrides[item.id] = item;
    _itemOverrides[item.name.toLowerCase()] = item;
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      final mapToSave = _itemOverrides.map((k, v) => MapEntry(k, v.toMap()));
      await prefs.setString(_overridePrefsKey, jsonEncode(mapToSave));
    } catch (e) {
      debugPrint('Error saving local food override: $e');
    }
  }

  Future<void> _removeLocalOverride(String id, String? name) async {
    _itemOverrides.remove(id);
    if (name != null) _itemOverrides.remove(name.toLowerCase());
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();
      final mapToSave = _itemOverrides.map((k, v) => MapEntry(k, v.toMap()));
      await prefs.setString(_overridePrefsKey, jsonEncode(mapToSave));
    } catch (e) {
      debugPrint('Error removing local override: $e');
    }
  }

  FoodItem _applyLocalOverride(FoodItem item) {
    final override = _itemOverrides[item.id] ?? _itemOverrides[item.name.toLowerCase()];
    if (override == null) return item;

    return item.copyWith(
      name: override.name,
      storageLocation: override.storageLocation,
      expiryDate: override.expiryDate,
      purchaseDate: override.purchaseDate,
      quantity: override.quantity,
      unit: override.unit,
      notes: override.notes,
      imageUrl: override.imageUrl ?? item.imageUrl,
    );
  }

  String? _extractFilenameFromUrl(String url) {
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return url;
  }

  SupabaseClient? get _client => supabaseClient;

  /// Sets up a Realtime WebSocket listener on `food_inventory_logs`
  /// and runs a periodic 4-second check as a reliable fallback.
  void _initRealtimeSubscription() {
    final client = _client;
    if (client == null) return;

    try {
      _realtimeChannel = client
          .channel('fridge_realtime_channel')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: SupabaseConstants.tableInventoryLogs,
            callback: (payload) {
              debugPrint('Supabase Realtime event on food_inventory_logs: ${payload.eventType}');
              _refreshAll();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Realtime subscription not available: $e');
    }

    // Polling backup in case Realtime replication publication is disabled on Supabase
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _refreshAll();
    });
  }

  Future<void> _refreshAll() async {
    try {
      await Future.wait([
        getItems(),
        getPendingRequests(),
      ]);
    } catch (e) {
      debugPrint('Error refreshing Supabase data: $e');
    }
  }

  String _extractCategory(FoodItem? item) {
    if (item?.notes != null && item!.notes!.startsWith('Category: ')) {
      return item.notes!.substring('Category: '.length).trim();
    }
    return 'General';
  }

  @override
  Future<List<FoodItem>> getItems({
    StorageLocation? location,
    ItemStatus? status,
  }) async {
    final client = _client;
    if (client == null) {
      return _cachedItems;
    }

    try {
      final now = DateTime.now();
      final List<FoodItem> mapped = [];

      // Query food_inventory_logs to compute true real-time inventory delta.
      final logsResponse = await client
          .from(SupabaseConstants.tableInventoryLogs)
          .select('*')
          .eq('has_food', true)
          .order('created_at', ascending: true);

      final List<dynamic> logRows = logsResponse as List<dynamic>;

      if (logRows.isNotEmpty) {
        final Map<String, _StockAgg> stockMap = {};

        for (final raw in logRows) {
          final r = raw as Map<String, dynamic>;
          final filename = r['filename'] as String? ?? '';
          final notes = r['notes'] as String? ?? '';
          final action = r['action_type'] as String? ?? 'input';
          final count = (r['item_count'] as num?)?.toDouble() ?? 1.0;
          final delta = action == 'input' ? count : -count;
          final createdAt = DateTime.tryParse(r['created_at']?.toString() ?? '')?.toLocal() ?? now;
          final detected = r['detected_items'] as List<dynamic>?;

          // RULE: Raw unconfirmed hardware captures ('input_' or 'output_') are PENDING requests.
          // They DO NOT enter or deduct from active inventory until user confirmation!
          final isRawHardwareCapture = filename.startsWith('input_') || filename.startsWith('output_');
          if (isRawHardwareCapture) {
            continue;
          }

          if (detected != null && detected.isNotEmpty) {
            for (final it in detected) {
              if (it is Map && it['name'] != null) {
                final itemUserId = it['user_id']?.toString() ?? _extractUserIdFromRow(r);
                if (!_isItemOwnedByCurrentUser(itemUserId)) {
                  continue;
                }
                final rawName = it['name'].toString().trim();
                if (rawName.isEmpty) continue;
                final normKey = rawName.toLowerCase();
                final existing = stockMap[normKey];
                final categoryStr = it['category']?.toString();
                final locStr = it['storage_location']?.toString() ?? it['location']?.toString();
                final loc = locStr != null ? StorageLocation.fromString(locStr) : StorageLocation.refrigerator;
                final expDateStr = it['expiry_date']?.toString();
                final parsedExp = expDateStr != null ? DateTime.tryParse(expDateStr)?.toLocal() : null;
                final purchDateStr = it['purchase_date']?.toString();
                final parsedPurch = purchDateStr != null ? DateTime.tryParse(purchDateStr)?.toLocal() : null;
                final unitStr = it['unit']?.toString();
                final customNotes = it['notes']?.toString();

                // Extract true ESP32 camera picture:
                // 1) From source_filename or photo_filename in detected_items
                // 2) From image_url in detected_items
                // 3) From row filename if not synthetic
                // 4) Regex fallback from notes e.g. "(input_1794...jpg)"
                String? photo;
                final rawSource = it['source_filename']?.toString() ?? it['photo_filename']?.toString();
                if (rawSource != null && rawSource.isNotEmpty) {
                  photo = rawSource;
                } else if (it['image_url'] != null && it['image_url'].toString().isNotEmpty) {
                  photo = it['image_url'].toString();
                } else if (filename.startsWith('input_')) {
                  photo = filename;
                } else if (notes.isNotEmpty) {
                  final match = RegExp(r'\((input_[^\)]+\.jpg)\)').firstMatch(notes);
                  if (match != null) {
                    photo = match.group(1);
                  }
                }

                if (existing == null) {
                  stockMap[normKey] = _StockAgg(
                    name: rawName,
                    quantity: delta,
                    category: categoryStr,
                    storageLocation: loc,
                    lastUpdated: createdAt,
                    photoFilename: photo,
                    expiryDate: parsedExp,
                    purchaseDate: parsedPurch,
                    unit: unitStr ?? 'pcs',
                    notes: customNotes,
                  );
                } else {
                  existing.quantity += delta;
                  existing.lastUpdated = createdAt;
                  if (categoryStr != null && categoryStr.isNotEmpty && categoryStr != 'General') {
                    existing.category = categoryStr;
                  }
                  if (locStr != null) {
                    existing.storageLocation = loc;
                  }
                  if (photo != null && photo.isNotEmpty && (action == 'input' || existing.photoFilename == null)) {
                    existing.photoFilename = photo;
                  }
                  if (parsedExp != null) {
                    existing.expiryDate = parsedExp;
                  }
                  if (parsedPurch != null) {
                    existing.purchaseDate = parsedPurch;
                  }
                  if (unitStr != null && unitStr.isNotEmpty) {
                    existing.unit = unitStr;
                  }
                  if (customNotes != null && customNotes.isNotEmpty) {
                    existing.notes = customNotes;
                  }
                }
              }
            }
          }
        }

        // Build FoodItems for items in stock (quantity > 0)
        for (final entry in stockMap.values) {
          if (entry.quantity > 0) {
            final imageUrl = entry.photoFilename != null && entry.photoFilename!.isNotEmpty
                ? SupabaseConstants.getPublicPhotoUrl(entry.photoFilename!)
                : null;

            final normKey = entry.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
            final id = 'sp_$normKey';

            var item = FoodItem(
              id: id,
              name: entry.name,
              storageLocation: entry.storageLocation,
              purchaseDate: entry.purchaseDate ?? entry.lastUpdated,
              expiryDate: entry.expiryDate ?? entry.lastUpdated.add(const Duration(days: 7)),
              quantity: entry.quantity,
              unit: entry.unit,
              status: ItemStatus.active,
              notes: entry.notes ?? (entry.category != null ? 'Category: ${entry.category}' : null),
              imageUrl: imageUrl,
            );

            item = _applyLocalOverride(item);

            mapped.add(item);
          }
        }
      }

      if (mapped.isEmpty) {
        _cachedItems = [];
        if (!_streamController.isClosed) _streamController.add([]);
        return [];
      }

      _cachedItems = mapped;
      if (!_streamController.isClosed) {
        _streamController.add(mapped);
      }

      if (location != null) {
        return mapped.where((item) => item.storageLocation == location).toList();
      }
      return mapped;
    } catch (e) {
      debugPrint('Failed to query Supabase food items: $e');
      return _cachedItems;
    }
  }

  @override
  Stream<List<FoodItem>> watchItems({
    StorageLocation? location,
    ItemStatus? status,
  }) {
    getItems(location: location, status: status).then((items) {
      if (!_streamController.isClosed) {
        _streamController.add(items);
      }
    });

    return _streamController.stream.map((items) {
      var filtered = items;
      if (location != null) {
        filtered = filtered.where((item) => item.storageLocation == location).toList();
      }
      if (status != null) {
        filtered = filtered.where((item) => item.status == status).toList();
      }
      return filtered;
    });
  }

  @override
  Future<FoodItem?> getItemById(String id) async {
    if (_cachedItems.isEmpty) {
      await getItems();
    }
    try {
      return _cachedItems.firstWhere(
        (item) => item.id == id || item.name.toLowerCase() == id.toLowerCase() || item.id == 'sp_${id.toLowerCase()}',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addItem(FoodItem item) async {
    final client = _client;
    if (client == null) {
      _cachedItems.add(item);
      if (!_streamController.isClosed) _streamController.add(List.from(_cachedItems));
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final category = _extractCategory(item);
      await client.from(SupabaseConstants.tableInventoryLogs).insert({
        'filename': 'app_in_${timestamp}_${item.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}.jpg',
        'action_type': 'input',
        'has_food': true,
        'item_count': item.quantity.toInt() > 0 ? item.quantity.toInt() : 1,
        'detected_items': [
          {
            'name': item.name,
            'user_id': _activeUserId,
            'category': category,
            'storage_location': item.storageLocation.name,
            'location': item.storageLocation.label,
            'expiry_date': item.expiryDate.toIso8601String(),
            'purchase_date': item.purchaseDate.toIso8601String(),
            'unit': item.unit,
            'notes': item.notes,
          }
        ],
        'notes': '${item.notes ?? "Manually registered via mobile app"} [uid:$_activeUserId]',
      });
      await getItems();
    } catch (e) {
      debugPrint('Supabase addItem error: $e');
    }
  }

  @override
  Future<void> updateItem(FoodItem item) async {
    FoodItem? prev;
    final idx = _cachedItems.indexWhere((i) => i.id == item.id);
    if (idx != -1) {
      prev = _cachedItems[idx];
      _cachedItems[idx] = item;
    } else {
      prev = _cachedItems.cast<FoodItem?>().firstWhere(
            (i) => i?.name.toLowerCase() == item.name.toLowerCase(),
            orElse: () => null,
          );
      _cachedItems.add(item);
    }

    // Always preserve image URL from previous record if not specified
    final effectiveItem = (item.imageUrl == null && prev?.imageUrl != null)
        ? item.copyWith(imageUrl: prev!.imageUrl)
        : item;

    if (idx != -1) {
      _cachedItems[idx] = effectiveItem;
    }

    // 1. Persist to local item overrides immediately
    await _saveLocalOverride(effectiveItem);

    if (!_streamController.isClosed) {
      _streamController.add(List.from(_cachedItems));
    }

    final client = _client;
    if (client == null) return;

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeName = effectiveItem.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      final prevQty = prev?.quantity ?? effectiveItem.quantity;
      final diff = effectiveItem.quantity - prevQty;
      final photo = effectiveItem.imageUrl != null ? _extractFilenameFromUrl(effectiveItem.imageUrl!) : null;
      final category = _extractCategory(effectiveItem);

      // A. If renamed, output the old name so it doesn't linger in stock
      if (prev != null && prev.name.trim().toLowerCase() != effectiveItem.name.trim().toLowerCase()) {
        final oldSafeName = prev.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        await client.from(SupabaseConstants.tableInventoryLogs).insert({
          'filename': 'app_out_${timestamp}_$oldSafeName.jpg',
          'action_type': 'output',
          'has_food': true,
          'item_count': prev.quantity.toInt() > 0 ? prev.quantity.toInt() : 1,
          'detected_items': [
            {
              'name': prev.name,
              'category': _extractCategory(prev),
            }
          ],
          'notes': 'Renamed to "${effectiveItem.name}" via mobile app',
        });
      }

      // B. Insert update log into food_inventory_logs
      final actionType = diff < 0 ? 'output' : 'input';
      final count = diff != 0
          ? diff.abs().toInt()
          : (prev != null && prev.name.trim().toLowerCase() != effectiveItem.name.trim().toLowerCase()
              ? effectiveItem.quantity.toInt()
              : 0);

      await client.from(SupabaseConstants.tableInventoryLogs).insert({
        'filename': 'app_edit_${timestamp}_$safeName.jpg',
        'action_type': actionType,
        'has_food': true,
        'item_count': count,
        'detected_items': [
          {
            'name': effectiveItem.name,
            'user_id': _activeUserId,
            'category': category,
            'storage_location': effectiveItem.storageLocation.name,
            'location': effectiveItem.storageLocation.label,
            'expiry_date': effectiveItem.expiryDate.toIso8601String(),
            'purchase_date': effectiveItem.purchaseDate.toIso8601String(),
            'unit': effectiveItem.unit,
            'notes': effectiveItem.notes,
            'photo_filename': photo,
            'source_filename': photo,
            'image_url': effectiveItem.imageUrl,
          }
        ],
        'notes': 'Food details updated via mobile app${diff != 0 ? " (quantity delta: $diff)" : ""} [uid:$_activeUserId]',
      });

      // C. Update latest existing intake row for this item in Supabase so primary record is updated
      final matchName = prev?.name ?? effectiveItem.name;
      final existingRows = await client
          .from(SupabaseConstants.tableInventoryLogs)
          .select('id, detected_items')
          .eq('has_food', true)
          .eq('action_type', 'input')
          .order('created_at', ascending: false)
          .limit(15);

      if (existingRows.isNotEmpty) {
        for (final row in existingRows) {
          final detected = row['detected_items'] as List<dynamic>?;
          if (detected != null && detected.isNotEmpty) {
            final first = detected.first as Map<String, dynamic>?;
            if (first != null && first['name']?.toString().toLowerCase() == matchName.toLowerCase()) {
              final rowId = row['id'];
              final updatedDetected = List<Map<String, dynamic>>.from(
                detected.map((e) => Map<String, dynamic>.from(e as Map)),
              );
              updatedDetected[0]['name'] = effectiveItem.name;
              updatedDetected[0]['location'] = effectiveItem.storageLocation.label;
              updatedDetected[0]['storage_location'] = effectiveItem.storageLocation.name;
              updatedDetected[0]['expiry_date'] = effectiveItem.expiryDate.toIso8601String();
              updatedDetected[0]['purchase_date'] = effectiveItem.purchaseDate.toIso8601String();
              updatedDetected[0]['unit'] = effectiveItem.unit;
              if (effectiveItem.notes != null) updatedDetected[0]['notes'] = effectiveItem.notes;
              if (photo != null) {
                updatedDetected[0]['photo_filename'] = photo;
                updatedDetected[0]['source_filename'] = photo;
              }
              if (effectiveItem.imageUrl != null) updatedDetected[0]['image_url'] = effectiveItem.imageUrl;

              await client
                  .from(SupabaseConstants.tableInventoryLogs)
                  .update({'detected_items': updatedDetected})
                  .eq('id', rowId);
              break;
            }
          }
        }
      }
      await getItems();
    } catch (e) {
      debugPrint('Supabase updateItem error: $e');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    final item = await getItemById(id);
    await _removeLocalOverride(id, item?.name);
    final qty = item?.quantity ?? 1.0;
    await markConsumed(id, quantity: qty, note: 'Permanently removed via mobile app');
  }

  @override
  Future<void> markConsumed(String id, {double? quantity, String? note}) async {
    final client = _client;
    final item = await getItemById(id);
    final itemName = item?.name ?? id.replaceFirst('sp_', '').replaceAll('_', ' ');
    final category = _extractCategory(item);
    final deductCount = quantity?.toInt() ?? 1;

    if (item != null) {
      if (item.quantity <= deductCount) {
        await _removeLocalOverride(id, itemName);
      } else {
        await _saveLocalOverride(item.copyWith(quantity: item.quantity - deductCount));
      }
    }

    if (client == null) {
      final idx = _cachedItems.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final cur = _cachedItems[idx];
        if (cur.quantity <= deductCount) {
          _cachedItems.removeAt(idx);
        } else {
          _cachedItems[idx] = cur.copyWith(quantity: cur.quantity - deductCount);
        }
        if (!_streamController.isClosed) _streamController.add(List.from(_cachedItems));
      }
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await client.from(SupabaseConstants.tableInventoryLogs).insert({
        'filename': 'app_out_${timestamp}_${itemName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}.jpg',
        'action_type': 'output',
        'has_food': true,
        'item_count': deductCount > 0 ? deductCount : 1,
        'detected_items': [
          {'name': itemName, 'category': category, 'user_id': _activeUserId}
        ],
        'notes': '${note ?? "Taken out via mobile app"} [uid:$_activeUserId]',
      });
      await getItems();
    } catch (e) {
      debugPrint('Supabase markConsumed error: $e');
    }
  }

  @override
  Future<void> markDiscarded(String id) async {
    final item = await getItemById(id);
    final qty = item?.quantity ?? 1.0;
    await markConsumed(id, quantity: qty, note: 'Discarded (spoiled/expired) via mobile app');
  }

  @override
  Future<List<ActivityLogItem>> getActivityLogs() async {
    final client = _client;
    if (client == null) {
      return [];
    }

    try {
      final response = await client
          .from(SupabaseConstants.tableInventoryLogs)
          .select('*')
          .order('created_at', ascending: false)
          .limit(40);

      final List<dynamic> rows = response as List<dynamic>;
      if (rows.isEmpty) {
        return [];
      }

      final List<ActivityLogItem> logs = [];

      for (final raw in rows) {
        final row = raw as Map<String, dynamic>;
        final reqUserId = _extractUserIdFromRow(row);
        if (!_isItemOwnedByCurrentUser(reqUserId)) {
          continue;
        }
        final String actionType = row['action_type'] as String? ?? 'input';
        final isInput = actionType == 'input';
        final String filename = row['filename'] as String? ?? '';
        final String? createdAtStr = row['created_at'] as String?;
        final DateTime timestamp = createdAtStr != null
            ? (DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now())
            : DateTime.now();

        final bool hasFood = row['has_food'] as bool? ?? true;
        String displayItemName = hasFood ? 'Grocery Item' : 'No Food Detected';
        final detected = row['detected_items'];
        if (detected is List && detected.isNotEmpty) {
          final first = detected.first;
          if (first is Map && first['name'] != null) {
            displayItemName = first['name'].toString();
            if (detected.length > 1) {
              displayItemName += ' +${detected.length - 1} more';
            }
          }
        }

        final double itemCount = (row['item_count'] as num?)?.toDouble() ?? 1.0;
        final String? notes = row['notes'] as String?;
        final String imageUrl = SupabaseConstants.getPublicPhotoUrl(filename);

        logs.add(
          ActivityLogItem(
            id: row['id']?.toString() ?? filename,
            actionType: isInput ? LogActionType.added : LogActionType.consumed,
            itemName: displayItemName,
            quantity: itemCount,
            unit: 'pcs',
            timestamp: timestamp,
            notes: notes,
            imageUrl: imageUrl,
          ),
        );
      }

      return logs;
    } catch (e) {
      debugPrint('Failed to query Supabase activity logs: $e');
      return [];
    }
  }

  // =========================================================================
  // PENDING REQUESTS API (FOOD IN / FOOD OUT ASYNCHRONOUS WORKFLOW)
  // =========================================================================

  @override
  Future<List<PendingFoodRequest>> getPendingRequests() async {
    final client = _client;
    if (client == null) {
      return _cachedPendingRequests;
    }

    try {
      final logsResponse = await client
          .from(SupabaseConstants.tableInventoryLogs)
          .select('*')
          .order('created_at', ascending: false);

      final List<dynamic> logRows = logsResponse as List<dynamic>;
      if (logRows.isEmpty) {
        _cachedPendingRequests = [];
        if (!_pendingRequestsController.isClosed) _pendingRequestsController.add([]);
        return [];
      }

      // 1. Collect all confirmed request references and locally dismissed IDs
      final Set<String> confirmedOrDismissedRefs = {};
      final prefs = await SharedPreferences.getInstance();
      final dismissedList = prefs.getStringList('dismissed_pending_requests') ?? [];
      confirmedOrDismissedRefs.addAll(dismissedList);

      for (final raw in logRows) {
        final r = raw as Map<String, dynamic>;
        final filename = r['filename'] as String? ?? '';
        final notes = r['notes'] as String? ?? '';
        final detected = r['detected_items'] as List<dynamic>?;

        // Check if this log is a confirmation referencing a hardware request
        if (filename.startsWith('app_in_') || filename.startsWith('app_out_')) {
          if (detected != null) {
            for (final it in detected) {
              if (it is Map) {
                final sourceReqId = it['source_request_id']?.toString();
                final sourceFilename = it['source_filename']?.toString();
                if (sourceReqId != null && sourceReqId.isNotEmpty) {
                  confirmedOrDismissedRefs.add(sourceReqId);
                }
                if (sourceFilename != null && sourceFilename.isNotEmpty) {
                  confirmedOrDismissedRefs.add(sourceFilename);
                }
              }
            }
          }

          // Also match regex in notes, e.g. "for request #14 (input_...)"
          final match = RegExp(r'\((input_[^\)]+|output_[^\)]+)\)').firstMatch(notes);
          if (match != null) {
            confirmedOrDismissedRefs.add(match.group(1)!);
          }
        }
      }

      // 2. Filter raw hardware captures that are not yet confirmed or dismissed
      final List<PendingFoodRequest> pending = [];
      for (final raw in logRows) {
        final r = raw as Map<String, dynamic>;
        final id = r['id']?.toString() ?? '';
        final filename = r['filename'] as String? ?? '';
        final actionType = r['action_type'] as String? ?? 'input';
        final isInput = actionType == 'input' || filename.startsWith('input_');

        final isHardwareCapture = filename.startsWith('input_') || filename.startsWith('output_');
        if (!isHardwareCapture) continue;

        // Skip if already confirmed or dismissed
        if (confirmedOrDismissedRefs.contains(id) || confirmedOrDismissedRefs.contains(filename)) {
          continue;
        }

        final reqUserId = _extractUserIdFromRow(r);
        if (!_isItemOwnedByCurrentUser(reqUserId)) {
          continue;
        }

        final hasFood = r['has_food'] as bool? ?? true;
        final createdAtStr = r['created_at']?.toString();
        final timestamp = createdAtStr != null
            ? (DateTime.tryParse(createdAtStr)?.toLocal() ?? DateTime.now())
            : DateTime.now();
        final notes = r['notes'] as String?;
        final imageUrl = SupabaseConstants.getPublicPhotoUrl(filename);

        String? aiName;
        String? aiCategory;

        final detected = r['detected_items'] as List<dynamic>?;
        if (detected != null && detected.isNotEmpty) {
          final first = detected.first;
          if (first is Map && first['name'] != null) {
            aiName = first['name'].toString();
            aiCategory = first['category']?.toString();
          }
        }

        pending.add(
          PendingFoodRequest(
            id: id,
            filename: filename,
            type: isInput ? PendingRequestType.intake : PendingRequestType.takeout,
            imageUrl: imageUrl,
            timestamp: timestamp,
            hasFood: hasFood,
            aiDetectedName: aiName,
            aiCategory: aiCategory,
            notes: notes,
            isConfirmed: false,
          ),
        );
      }

      _cachedPendingRequests = pending;
      if (!_pendingRequestsController.isClosed) {
        _pendingRequestsController.add(pending);
      }
      return pending;
    } catch (e) {
      debugPrint('Failed to query Supabase pending requests: $e');
      return _cachedPendingRequests;
    }
  }

  @override
  Stream<List<PendingFoodRequest>> watchPendingRequests() {
    getPendingRequests().then((reqs) {
      if (!_pendingRequestsController.isClosed) {
        _pendingRequestsController.add(reqs);
      }
    });
    return _pendingRequestsController.stream;
  }

  @override
  Future<void> confirmIntake(PendingFoodRequest request, FoodItem confirmedItem) async {
    final client = _client;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final category = _extractCategory(confirmedItem);

    if (client != null) {
      try {
        await client.from(SupabaseConstants.tableInventoryLogs).insert({
          'filename': 'app_in_${timestamp}_${confirmedItem.name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}.jpg',
          'action_type': 'input',
          'has_food': true,
          'item_count': confirmedItem.quantity > 0 ? confirmedItem.quantity.toInt() : 1,
          'detected_items': [
            {
              'name': confirmedItem.name,
              'user_id': _activeUserId,
              'category': category,
              'storage_location': confirmedItem.storageLocation.name,
              'location': confirmedItem.storageLocation.label,
              'source_request_id': request.id,
              'source_filename': request.filename,
              'photo_filename': request.filename,
              'image_url': confirmedItem.imageUrl ?? request.imageUrl,
            }
          ],
          'notes': 'Confirmed intake for request #${request.id} (${request.filename}) [uid:$_activeUserId]',
        });
      } catch (e) {
        debugPrint('Supabase confirmIntake error: $e');
      }
    }

    await getItems();
    await getPendingRequests();
  }

  @override
  Future<void> confirmTakeOut(PendingFoodRequest request, List<FoodDeduction> deductions) async {
    final client = _client;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (client != null) {
      try {
        for (final deduction in deductions) {
          final count = deduction.quantity > 0 ? deduction.quantity.toInt() : 1;
          await client.from(SupabaseConstants.tableInventoryLogs).insert({
            'filename': 'app_out_${timestamp}_${deduction.foodItemName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}.jpg',
            'action_type': 'output',
            'has_food': true,
            'item_count': count,
            'detected_items': [
              {
                'name': deduction.foodItemName,
                'user_id': _activeUserId,
                'category': 'General',
                'source_request_id': request.id,
                'source_filename': request.filename,
              }
            ],
            'notes': 'Confirmed takeout for request #${request.id} (${request.filename}) [uid:$_activeUserId]',
          });
        }
      } catch (e) {
        debugPrint('Supabase confirmTakeOut error: $e');
      }
    }

    await getItems();
    await getPendingRequests();
  }

  @override
  Future<void> dismissPendingRequest(String requestId, String filename) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedList = prefs.getStringList('dismissed_pending_requests') ?? [];
    if (!dismissedList.contains(requestId)) dismissedList.add(requestId);
    if (!dismissedList.contains(filename)) dismissedList.add(filename);
    await prefs.setStringList('dismissed_pending_requests', dismissedList);
    await getPendingRequests();
  }

  void dispose() {
    _pollingTimer?.cancel();
    _realtimeChannel?.unsubscribe();
    _streamController.close();
    _pendingRequestsController.close();
  }
}
