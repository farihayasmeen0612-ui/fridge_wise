import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_management/features/auth/data/auth_provider.dart';
import 'package:food_management/features/inventory/data/inventory_providers.dart';
import 'package:food_management/features/inventory/data/mock_food_repository.dart';
import 'package:food_management/main.dart';

void main() {
  testWidgets('Complete UI: App boots, displays dashboard metrics, and navigates primary tabs', (WidgetTester tester) async {
    // Build the app inside a ProviderScope with authenticated session & test inventory
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _WidgetTestAuthNotifier()),
          foodRepositoryProvider.overrideWithValue(MockFoodRepository(populateSeedData: true)),
        ],
        child: const FoodManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial screen is Dashboard with Smart Fridge greeting
    expect(find.textContaining('Alex!'), findsOneWidget);
    expect(find.text('TRACKED'), findsOneWidget);
    expect(find.text('EXPIRING'), findsOneWidget);
    expect(find.text('EXPIRED'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // 10 initial active seed items

    // Verify header actions: Notification Icon -> Theme Toggle -> Sign Out Icon
    expect(find.byTooltip('Notification Center'), findsOneWidget);
    expect(find.byTooltip('Sign Out'), findsOneWidget);

    // Verify Sign Out tap shows confirmation dialog and Cancel retains user on Dashboard
    await tester.tap(find.byTooltip('Sign Out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Out?'), findsNothing);

    // Verify dashboard does not display manual IN/OUT action buttons
    expect(find.text('Add Food (IN)'), findsNothing);
    expect(find.text('Take Out (OUT)'), findsNothing);

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
    expect(find.text('Refrigerator'), findsWidgets);
    expect(find.text('Freezer'), findsWidgets);
    expect(find.text('Deep Fridge'), findsWidgets);

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
    expect(find.textContaining('Zero-Waste'), findsAtLeastNWidgets(1));

    // Tap on Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Verify Settings screen is displayed with Premium Nature sections
    expect(find.text('PREFERENCES'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('CONNECTED HARDWARE'), findsOneWidget);
  });
}

class _WidgetTestAuthNotifier extends AuthNotifier {
  @override
  AuthUserState build() {
    return const AuthUserState(
      isAuthenticated: true,
      uid: 'widget_test_user',
      email: 'test@smartfridge.local',
      name: 'Alex',
    );
  }
}
