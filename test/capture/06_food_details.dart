import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/features/inventory/presentation/screens/food_details_screen.dart';
import 'capture_helper.dart';

void main() {
  testWidgets('06_food_details', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final key = GlobalKey();
    await tester.pumpWidget(wrapScreen(const FoodDetailsScreen(itemId: 'seed-item-5'), key));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await captureAndExit(key, '06_food_details_screen.png');
  });
}

