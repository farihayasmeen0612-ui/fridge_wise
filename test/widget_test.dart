import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_management/main.dart';

void main() {
  testWidgets('Complete UI: App boots, displays dashboard metrics, and navigates primary tabs', (WidgetTester tester) async {
    // Build the app inside a ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial screen is Dashboard with Smart Fridge header
    expect(find.text('Smart Fridge Monitor'), findsOneWidget);
    expect(find.text('TRACKED'), findsOneWidget);
    expect(find.text('EXPIRING'), findsOneWidget);
    expect(find.text('EXPIRED'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // 10 initial active seed items

    // Verify primary actions
    expect(find.text('Add Food (IN)'), findsOneWidget);
    expect(find.text('Take Out (OUT)'), findsOneWidget);

    // Verify navigation bar destinations exist
    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));
    expect(find.text('Fridge'), findsAtLeastNWidgets(1));
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap on Fridge tab
    await tester.tap(find.byIcon(Icons.kitchen_outlined));
    await tester.pumpAndSettle();

    // Verify Inventory screen is displayed with search & items
    expect(find.text('My Fridge Inventory'), findsOneWidget);
    expect(find.text('All Zones'), findsOneWidget);

    // Tap on Calendar tab
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();

    // Verify Expiry Calendar screen is displayed
    expect(find.text('Expiry Calendar & Agenda'), findsOneWidget);

    // Tap on Recipes tab
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    // Verify Recipes screen is displayed
    expect(find.text('Zero-Waste Recipes'), findsOneWidget);
    expect(find.text('Pan-Seared Salmon with Garlic Spinach'), findsOneWidget);

    // Tap on Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify Settings screen is displayed
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('EXPIRY NOTIFICATIONS'), findsOneWidget);
  });
}
