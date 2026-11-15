import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/data/inventory_providers.dart';
import '../../inventory/domain/models/food_item.dart';
import '../domain/models/pending_food_request.dart';

class PendingRequestsNotifier extends Notifier<List<PendingFoodRequest>> {
  @override
  List<PendingFoodRequest> build() {
    final repo = ref.watch(foodRepositoryProvider);

    final sub = repo.watchPendingRequests().listen((reqs) {
      state = reqs;
    });
    ref.onDispose(sub.cancel);

    _load(repo);
    return const [];
  }

  Future<void> _load(dynamic repo) async {
    final reqs = await repo.getPendingRequests();
    state = reqs;
  }

  Future<void> refresh() async {
    final repo = ref.read(foodRepositoryProvider);
    state = await repo.getPendingRequests();
  }

  Future<void> confirmIntake(PendingFoodRequest request, FoodItem confirmedItem) async {
    final repo = ref.read(foodRepositoryProvider);
    await repo.confirmIntake(request, confirmedItem);
    // Invalidate inventory so active items update immediately
    ref.invalidate(inventoryNotifierProvider);
    state = await repo.getPendingRequests();
  }

  Future<void> confirmTakeOut(PendingFoodRequest request, List<FoodDeduction> deductions) async {
    final repo = ref.read(foodRepositoryProvider);
    await repo.confirmTakeOut(request, deductions);
    // Invalidate inventory so deducted items update immediately
    ref.invalidate(inventoryNotifierProvider);
    state = await repo.getPendingRequests();
  }

  Future<void> dismiss(PendingFoodRequest request) async {
    final repo = ref.read(foodRepositoryProvider);
    await repo.dismissPendingRequest(request.id, request.filename);
    state = await repo.getPendingRequests();
  }
}

final pendingRequestsProvider =
    NotifierProvider<PendingRequestsNotifier, List<PendingFoodRequest>>(
  PendingRequestsNotifier.new,
);

final pendingIntakeRequestsProvider = Provider<List<PendingFoodRequest>>((ref) {
  final all = ref.watch(pendingRequestsProvider);
  return all.where((r) => r.isIntake).toList();
});

final pendingTakeOutRequestsProvider = Provider<List<PendingFoodRequest>>((ref) {
  final all = ref.watch(pendingRequestsProvider);
  return all.where((r) => r.isTakeout).toList();
});

final pendingRequestsCountProvider = Provider<int>((ref) {
  final all = ref.watch(pendingRequestsProvider);
  return all.length;
});

final pendingRequestByIdProvider =
    Provider.family<PendingFoodRequest?, String>((ref, id) {
  final all = ref.watch(pendingRequestsProvider);
  try {
    return all.firstWhere((r) => r.id == id || r.filename == id);
  } catch (_) {
    return null;
  }
});

