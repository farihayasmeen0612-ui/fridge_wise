import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/core/theme/app_theme.dart';
import 'package:food_management/features/auth/data/auth_provider.dart';
import 'package:food_management/features/settings/presentation/screens/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders user profile details, edit actions, and security options', (tester) async {
    // Set larger surface size to prevent scroll clipping
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(() => _TestAuthNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Profile Screen title and header
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Alex'), findsWidgets);
    expect(find.textContaining('UID:'), findsNothing);

    // 2. Verify Personal Information section
    expect(find.text('PERSONAL INFORMATION'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);

    // 3. Verify Security & Account Actions
    expect(find.text('SECURITY'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('ACCOUNT ACTIONS'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
  });
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthUserState build() {
    return const AuthUserState(
      isAuthenticated: true,
      uid: 'test_uid_123',
      name: 'Alex',
      email: 'alex@smartfridge.local',
      phone: '+1 (555) 019-2831',
    );
  }
}
