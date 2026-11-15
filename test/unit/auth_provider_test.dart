import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_management/core/router/app_router.dart';
import 'package:food_management/features/auth/data/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthUserState Model Tests', () {
    test('Default AuthUserState is unauthenticated with empty attributes', () {
      const state = AuthUserState();
      expect(state.isAuthenticated, isFalse);
      expect(state.uid, isEmpty);
      expect(state.email, isEmpty);
      expect(state.name, isEmpty);
      expect(state.phone, isEmpty);
      expect(state.photoUrl, isNull);
    });

    test('AuthUserState.unauthenticated constant is unauthenticated', () {
      expect(AuthUserState.unauthenticated.isAuthenticated, isFalse);
      expect(AuthUserState.unauthenticated.uid, isEmpty);
    });

    test('AuthUserState.fromSupabaseUser extracts metadata correctly', () {
      final user = User(
        id: 'supa_user_999',
        appMetadata: {},
        userMetadata: {
          'name': 'Jane Doe',
          'phone': '+1 234 567 8900',
          'avatar_url': 'https://example.com/avatar.png',
        },
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'jane@example.com',
      );

      final state = AuthUserState.fromSupabaseUser(user);
      expect(state.isAuthenticated, isTrue);
      expect(state.uid, 'supa_user_999');
      expect(state.email, 'jane@example.com');
      expect(state.name, 'Jane Doe');
      expect(state.phone, '+1 234 567 8900');
      expect(state.photoUrl, 'https://example.com/avatar.png');
    });

    test('AuthUserState.fromSupabaseUser falls back to email prefix if name is absent', () {
      final user = User(
        id: 'supa_user_888',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: '2026-01-01T00:00:00.000Z',
        email: 'chef_mario@kitchen.com',
      );

      final state = AuthUserState.fromSupabaseUser(user);
      expect(state.isAuthenticated, isTrue);
      expect(state.name, 'chef_mario');
    });
  });

  group('AuthNotifier & Route Protection Tests', () {
    test('AuthNotifier initializes to unauthenticated in test environment', () {
      final container = ProviderContainer();
      final auth = container.read(authProvider);
      expect(auth.isAuthenticated, isFalse);
      expect(auth.uid, isEmpty);
    });

    test('signIn throws AuthException when Supabase client is uninitialized', () async {
      final container = ProviderContainer();
      final notifier = container.read(authProvider.notifier);

      expect(
        () => notifier.signIn('unknown@user.com', 'wrongpassword'),
        throwsA(isA<AuthException>()),
      );
    });

    test('signUp throws AuthException when Supabase client is uninitialized', () async {
      final container = ProviderContainer();
      final notifier = container.read(authProvider.notifier);

      expect(
        () => notifier.signUp('New User', 'new@user.com', 'pass12345'),
        throwsA(isA<AuthException>()),
      );
    });

    test('signOut resets authenticated state to unauthenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _MockLoggedInAuthNotifier()),
        ],
      );

      expect(container.read(authProvider).isAuthenticated, isTrue);
      await container.read(authProvider.notifier).signOut();
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });

    test('RouterNotifier fires when auth state changes', () {
      final container = ProviderContainer();
      final routerNotifier = container.read(routerNotifierProvider);

      var notified = false;
      routerNotifier.addListener(() {
        notified = true;
      });

      // Override state
      container.read(authProvider.notifier).state = const AuthUserState(
        isAuthenticated: true,
        uid: 'user_live_123',
        email: 'live@user.com',
      );

      expect(notified, isTrue);
    });
  });
}

class _MockLoggedInAuthNotifier extends AuthNotifier {
  @override
  AuthUserState build() {
    return const AuthUserState(
      isAuthenticated: true,
      uid: 'logged_in_user_001',
      email: 'test@smartfridge.com',
      name: 'Test User',
    );
  }
}
