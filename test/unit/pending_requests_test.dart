import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/inventory/data/mock_food_repository.dart';
import 'package:food_management/features/inventory/domain/models/food_item.dart';
import 'package:food_management/features/inventory/domain/models/storage_location.dart';
import 'package:food_management/features/scan/domain/models/pending_food_request.dart';

void main() {
  group('Asynchronous Food IN & Food OUT Workflow Tests', () {
    late MockFoodRepository repository;
    final now = DateTime.now();

    setUp(() {
      repository = MockFoodRepository(populateSeedData: false);
    });

    test('Raw hardware capture is pending and does NOT enter active inventory automatically', () async {
      // Create a pending intake from ESP32 capture
      final intakeReq = PendingFoodRequest(
        id: 'req-in-1',
        filename: 'input_1001_abc.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_1001_abc.jpg',
        timestamp: now,
        aiDetectedName: 'Green Chili',
        aiCategory: 'Vegetable',
      );

      repository.addPendingRequest(intakeReq);

      // Verify active inventory is STILL EMPTY
      final activeItems = await repository.getItems();
      expect(activeItems, isEmpty, reason: 'Unconfirmed capture must not enter active inventory');

      // Verify request is pending
      final pendingList = await repository.getPendingRequests();
      expect(pendingList.length, 1);
      expect(pendingList.first.aiDetectedName, 'Green Chili');
    });

    test('Confirming intake enters item into active inventory and clears pending request', () async {
      final intakeReq = PendingFoodRequest(
        id: 'req-in-2',
        filename: 'input_1002_def.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_1002_def.jpg',
        timestamp: now,
        aiDetectedName: 'Fresh Tomato',
        aiCategory: 'Produce',
      );

      repository.addPendingRequest(intakeReq);

      // User reviews and confirms details
      final confirmedItem = FoodItem(
        id: 'confirmed-tomato-1',
        name: 'Fresh Organic Tomato',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now,
        expiryDate: now.add(const Duration(days: 7)),
        quantity: 2.0,
        unit: 'pcs',
      );

      await repository.confirmIntake(intakeReq, confirmedItem);

      // Verify active inventory now has the confirmed item
      final activeItems = await repository.getItems();
      expect(activeItems.length, 1);
      expect(activeItems.first.name, 'Fresh Organic Tomato');
      expect(activeItems.first.quantity, 2.0);

      // Verify pending list is now empty
      final pendingList = await repository.getPendingRequests();
      expect(pendingList, isEmpty);
    });

    test('Food OUT: Photo is reviewed without AI, and user manually selects items to deduct', () async {
      // Seed an active item first
      final milkItem = FoodItem(
        id: 'item-milk-1',
        name: 'Whole Milk',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now,
        expiryDate: now.add(const Duration(days: 5)),
        quantity: 2.0,
        unit: 'L',
      );
      await repository.addItem(milkItem);

      // Hardware OUT button pressed: photo captured without AI
      final outReq = PendingFoodRequest(
        id: 'req-out-1',
        filename: 'output_2001_ghi.jpg',
        type: PendingRequestType.takeout,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/output_2001_ghi.jpg',
        timestamp: now,
        aiDetectedName: null, // Strictly NO AI for Food OUT
        aiCategory: null,
      );
      repository.addPendingRequest(outReq);

      // Inventory remains 2.0 L until confirmation
      var activeItems = await repository.getItems();
      expect(activeItems.first.quantity, 2.0, reason: 'Inventory must not deduct before confirmation');

      // User visually verifies photo and selects 1.0 L Whole Milk removed
      final deductions = [
        const FoodDeduction(
          foodItemId: 'item-milk-1',
          foodItemName: 'Whole Milk',
          quantity: 1.0,
          unit: 'L',
        ),
      ];

      await repository.confirmTakeOut(outReq, deductions);

      // Inventory is now deducted
      activeItems = await repository.getItems();
      expect(activeItems.first.quantity, 1.0);

      // Pending takeout request is resolved
      final pendingList = await repository.getPendingRequests();
      expect(pendingList, isEmpty);
    });

    test('Dismissing a pending request leaves audit records intact', () async {
      final intakeReq = PendingFoodRequest(
        id: 'req-in-discard-1',
        filename: 'input_3001_jkl.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_3001_jkl.jpg',
        timestamp: now,
        aiDetectedName: 'Empty Hand',
        hasFood: false,
      );

      repository.addPendingRequest(intakeReq);

      // Dismiss request
      await repository.dismissPendingRequest(intakeReq.id, intakeReq.filename);

      final pendingList = await repository.getPendingRequests();
      expect(pendingList, isEmpty);

      // Active inventory untouched
      final activeItems = await repository.getItems();
      expect(activeItems, isEmpty);
    });

    test('Non-food capture (hasFood == false) can be manually named and entered into inventory', () async {
      final nonFoodReq = PendingFoodRequest(
        id: 'req-in-nonfood-1',
        filename: 'input_15329_867c.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_15329_867c.jpg',
        timestamp: now,
        hasFood: false,
        aiDetectedName: null,
      );

      repository.addPendingRequest(nonFoodReq);

      // Verify request is pending with no food detected
      final pendingList = await repository.getPendingRequests();
      expect(pendingList.length, 1);
      expect(pendingList.first.hasFood, false);
      expect(pendingList.first.aiDetectedName, isNull);

      // User manually enters a food name and confirms
      final manuallyNamedItem = FoodItem(
        id: 'food_manual_1',
        name: 'Whole Wheat Bread',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now,
        expiryDate: now.add(const Duration(days: 7)),
        quantity: 1.0,
        unit: 'pcs',
      );

      await repository.confirmIntake(nonFoodReq, manuallyNamedItem);

      // Verify inventory has item with manually typed name
      final activeItems = await repository.getItems();
      expect(activeItems.length, 1);
      expect(activeItems.first.name, 'Whole Wheat Bread');

      // Verify pending request is cleared
      final remainingPending = await repository.getPendingRequests();
      expect(remainingPending, isEmpty);
    });

    test('Filtering pending requests cleanly separates Food IN from Food OUT captures', () async {
      repository.addPendingRequest(PendingFoodRequest(
        id: 'in-1',
        filename: 'input_1.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_1.jpg',
        timestamp: now,
        aiDetectedName: 'Apple',
      ));
      repository.addPendingRequest(PendingFoodRequest(
        id: 'in-2',
        filename: 'input_2.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_2.jpg',
        timestamp: now,
        hasFood: false,
      ));
      repository.addPendingRequest(PendingFoodRequest(
        id: 'out-1',
        filename: 'output_1.jpg',
        type: PendingRequestType.takeout,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/output_1.jpg',
        timestamp: now,
      ));

      final all = await repository.getPendingRequests();
      expect(all.length, 3);

      final intakes = all.where((r) => r.isIntake).toList();
      expect(intakes.length, 2);
      expect(intakes.any((r) => r.id == 'in-1'), isTrue);
      expect(intakes.any((r) => r.id == 'in-2'), isTrue);

      final takeouts = all.where((r) => r.isTakeout).toList();
      expect(takeouts.length, 1);
      expect(takeouts.first.id, 'out-1');
    });

    test('Confirming one intake leaves other pending intakes available for review', () async {
      final req1 = PendingFoodRequest(
        id: 'in-multi-1',
        filename: 'input_multi_1.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_multi_1.jpg',
        timestamp: now,
        aiDetectedName: 'Banana',
      );
      final req2 = PendingFoodRequest(
        id: 'in-multi-2',
        filename: 'input_multi_2.jpg',
        type: PendingRequestType.intake,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/input_multi_2.jpg',
        timestamp: now,
        aiDetectedName: 'Orange',
      );

      repository.addPendingRequest(req1);
      repository.addPendingRequest(req2);

      expect((await repository.getPendingRequests()).length, 2);

      // Confirm only req1
      final confirmedBanana = FoodItem(
        id: 'banana-item',
        name: 'Fresh Banana',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now,
        expiryDate: now.add(const Duration(days: 5)),
        quantity: 3.0,
        unit: 'pcs',
      );
      await repository.confirmIntake(req1, confirmedBanana);

      // Verify req1 entered inventory
      final active = await repository.getItems();
      expect(active.length, 1);
      expect(active.first.name, 'Fresh Banana');

      // Verify req2 remains pending and available
      final remaining = await repository.getPendingRequests();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'in-multi-2');
      expect(remaining.first.aiDetectedName, 'Orange');
    });

    test('Confirming one removal leaves other pending removals available for review', () async {
      final reqOut1 = PendingFoodRequest(
        id: 'out-multi-1',
        filename: 'output_multi_1.jpg',
        type: PendingRequestType.takeout,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/output_multi_1.jpg',
        timestamp: now,
      );
      final reqOut2 = PendingFoodRequest(
        id: 'out-multi-2',
        filename: 'output_multi_2.jpg',
        type: PendingRequestType.takeout,
        imageUrl: 'https://test.supabase.co/storage/v1/object/public/Photos/output_multi_2.jpg',
        timestamp: now,
      );

      repository.addPendingRequest(reqOut1);
      repository.addPendingRequest(reqOut2);

      // Initial food in inventory
      await repository.addItem(FoodItem(
        id: 'food-milk',
        name: 'Whole Milk',
        storageLocation: StorageLocation.refrigerator,
        purchaseDate: now,
        expiryDate: now.add(const Duration(days: 4)),
        quantity: 2.0,
        unit: 'bottles',
      ));

      // Confirm only reqOut1 with 1 bottle deducted
      await repository.confirmTakeOut(reqOut1, [
        const FoodDeduction(
          foodItemId: 'food-milk',
          foodItemName: 'Whole Milk',
          quantity: 1.0,
          unit: 'bottles',
        ),
      ]);

      // Inventory updated
      final active = await repository.getItems();
      expect(active.first.quantity, 1.0);

      // reqOut2 remains pending
      final remaining = await repository.getPendingRequests();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'out-multi-2');
    });
  });
}

