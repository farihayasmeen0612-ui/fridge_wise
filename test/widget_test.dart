import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_management/main.dart';

void main() {
  testWidgets('Phase 1 & 2: App boots, shows live summary metrics, and navigates tabs', (WidgetTester tester) async {
    // Build the app inside a ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial screen is Dashboard
    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Smart Fridge System Active'), findsOneWidget);

    // Verify Phase 2 live summary KPI chips are displayed
    expect(find.text('Tracked'), findsOneWidget);
    expect(find.text('Expiring Soon'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // 10 initial active seed items

    // Verify navigation bar destinations exist
    expect(find.text('Fridge'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    // Verify Settings screen is displayed
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Tap on Fridge tab
    await tester.tap(find.text('Fridge'));
    await tester.pumpAndSettle();

    // Verify Fridge screen is displayed
    expect(find.text('My Fridge'), findsOneWidget);
    expect(find.text('Fridge Inventory'), findsOneWidget);
  });
}
