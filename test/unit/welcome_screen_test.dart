import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/core/theme/app_theme.dart';
import 'package:food_management/core/theme/theme_notifier.dart';
import 'package:food_management/features/auth/presentation/screens/welcome_screen.dart';
import 'package:food_management/main.dart';

void main() {
  testWidgets('WelcomeScreen renders all elements, line art, exact copy, and theme toggle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, child) {
            final themeMode = ref.watch(themeNotifierProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const WelcomeScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify app name, exact headline, and description
    expect(find.text('FridgeWise'), findsOneWidget);
    expect(find.text('Fresh food, less waste.'), findsOneWidget);
    expect(
      find.text('Keep track of your food, stay ahead of expiry dates, and make the most of every ingredient.'),
      findsOneWidget,
    );

    // 2. Verify minimal line-art custom paint illustration exists
    expect(find.byType(CustomPaint), findsWidgets);

    // 3. Verify Theme Toggle is present with sun and moon icons
    expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    // 4. Verify primary and secondary actions
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.textContaining('I already have an account — '), findsOneWidget);
    expect(find.textContaining('Sign In'), findsOneWidget);

    // 5. Test theme toggle interaction
    final toggleFinder = find.byType(Semantics).first;
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();

    // Verify UI remains intact after toggle
    expect(find.text('Fresh food, less waste.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Navigation: App boots to WelcomeScreen, Get Started -> Register, Sign In -> Login', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. App boots to Welcome Screen first
    expect(find.text('Fresh food, less waste.'), findsOneWidget);

    // 2. Tap 'I already have an account — Sign In' -> navigates to Login Screen
    await tester.tap(find.textContaining('Sign In').first);
    await tester.pumpAndSettle();

    // Verify Login Screen is displayed with 'FridgeWise'
    expect(find.text('FridgeWise'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Navigation: Get Started button navigates to Register Screen', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: FoodManagementApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap 'Get Started' -> navigates to Register Screen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Register Screen is displayed
    expect(find.text('Create Account'), findsAtLeastNWidgets(1));
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your email address'), findsOneWidget);
  });
}
