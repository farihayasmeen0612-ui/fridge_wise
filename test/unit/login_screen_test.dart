import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/core/presentation/components/fridge_logo.dart';
import 'package:food_management/core/theme/app_theme.dart';
import 'package:food_management/core/theme/theme_notifier.dart';
import 'package:food_management/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays curved layout, FridgeWiseLogo with leaf, form fields, and theme toggle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeNotifierProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify app name is 'FridgeWise'
    expect(find.text('FridgeWise'), findsOneWidget);

    // 2. Verify dedicated refrigerator logo with leaf detail is present
    expect(find.byType(FridgeWiseLogo), findsOneWidget);

    // 3. Verify Theme Toggle is present with sun and moon icons in upper right
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    // 4. Verify Form Elements inside the curved panel
    expect(find.text('Sign In'), findsAtLeastNWidgets(2)); // Heading & Button
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // 5. Verify password visibility toggle
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // 6. Test theme toggle interaction
    final toggleFinder = find.byType(Semantics).first;
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    // Still renders cleanly after toggling to dark mode
    expect(find.text('FridgeWise'), findsOneWidget);
    expect(find.byType(FridgeWiseLogo), findsOneWidget);
  });

  testWidgets('LoginScreen verifies refined colors and responsive panel proportions', (tester) async {
    // Set a typical modern phone viewport (393 x 873, Xiaomi/Pixel/iPhone)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify warm ivory card color (#F4F5ED) and 36dp rounded corners
    final panelFinder = find.byWidgetPredicate((widget) {
      if (widget is Container && widget.decoration is BoxDecoration) {
        final box = widget.decoration as BoxDecoration;
        return box.color == const Color(0xFFF4F5ED) &&
            box.borderRadius == BorderRadius.circular(36);
      }
      return false;
    });
    expect(panelFinder, findsOneWidget);

    // 2. Verify input field background color (#EAEFE7)
    final textFieldFinder = find.byType(TextField).first;
    final textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.decoration?.fillColor, const Color(0xFFEAEFE7));

    // 3. Verify that the panel has a compact height on tall screens
    final panelSize = tester.getSize(panelFinder);
    expect(panelSize.height, lessThan(520)); // Compact, no excessive empty void
  });
}
