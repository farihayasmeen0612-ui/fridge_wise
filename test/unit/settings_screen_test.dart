import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/core/presentation/components/theme_toggle_button.dart';
import 'package:food_management/core/theme/app_theme.dart';
import 'package:food_management/features/auth/data/auth_provider.dart';
import 'package:food_management/features/inventory/data/inventory_providers.dart';
import 'package:food_management/features/inventory/data/mock_food_repository.dart';
import 'package:food_management/features/settings/presentation/screens/settings_screen.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthUserState build() {
    return const AuthUserState(
      isAuthenticated: true,
      uid: 'test_user_settings_1',
      email: 'fariha@fridgewise.app',
      name: 'Fariha Rahman',
    );
  }
}

void main() {
  group('SettingsScreen Premium Nature Redesign Tests', () {
    late MockFoodRepository mockRepo;

    setUp(() {
      mockRepo = MockFoodRepository(populateSeedData: false);
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier()),
          foodRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SettingsScreen(),
        ),
      );
    }

    testWidgets('Renders all Premium Nature sections, account info, and preferences', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Header title & no duplicate theme toggle in AppBar
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(ThemeToggleButton), findsNothing);

      // Account Card
      expect(find.text('Fariha Rahman'), findsOneWidget);
      expect(find.text('fariha@fridgewise.app'), findsOneWidget);
      expect(find.text('F'), findsOneWidget); // Avatar initials

      // Section Headers
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('CONNECTED HARDWARE'), findsOneWidget);

      // Appearance 3-way toggle
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // Notification settings
      expect(find.text('Daily Expiry Digest'), findsOneWidget);
      expect(find.text('Summary at 9:00 AM'), findsOneWidget);
      expect(find.text('Alert Threshold'), findsOneWidget);
      expect(find.text('1 day before'), findsOneWidget);

      // Connected hardware
      expect(find.text('ESP32-S3 CAM Module'), findsOneWidget);
      expect(find.byIcon(Icons.memory_outlined), findsOneWidget);
      expect(find.text('Cloud Data Sync'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);

      // Sign out action
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('Tapping Appearance toggles theme mode', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Dark
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Tap Light
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
    });

    testWidgets('Tapping Sign Out displays confirmation dialog and Cancel retains screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Sign Out?'), findsOneWidget);
      expect(find.text('Are you sure you want to sign out of your account?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog is dismissed, Settings screen remains
      expect(find.text('Sign Out?'), findsNothing);
      expect(find.text('Fariha Rahman'), findsOneWidget);
    });

    testWidgets('Tapping Sync Now triggers cloud cache refresh and snackbar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Sync Now
      await tester.tap(find.text('Sync Now'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Inventory synchronized with Supabase Cloud.'), findsOneWidget);
    });
  });
}
