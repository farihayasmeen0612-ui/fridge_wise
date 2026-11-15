import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class AuthUserState {
  const AuthUserState({
    this.isAuthenticated = false,
    this.uid = '',
    this.email = '',
    this.name = '',
    this.phone = '',
    this.photoUrl,
  });

  final bool isAuthenticated;
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String? photoUrl;

  static const unauthenticated = AuthUserState(
    isAuthenticated: false,
    uid: '',
    email: '',
    name: '',
    phone: '',
    photoUrl: null,
  );

  factory AuthUserState.fromSupabaseUser(User user) {
    final meta = user.userMetadata ?? {};
    final metaName = meta['name'] as String?;
    final emailName = user.email != null && user.email!.contains('@')
        ? user.email!.split('@').first
        : 'User';
    return AuthUserState(
      isAuthenticated: true,
      uid: user.id,
      email: user.email ?? '',
      name: (metaName != null && metaName.isNotEmpty) ? metaName : emailName,
      phone: user.phone ?? (meta['phone'] as String? ?? ''),
      photoUrl: meta['avatar_url'] as String?,
    );
  }

  AuthUserState copyWith({
    bool? isAuthenticated,
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? photoUrl,
    bool clearPhoto = false,
  }) {
    return AuthUserState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
    );
  }
}

class AuthNotifier extends Notifier<AuthUserState> {
  @override
  AuthUserState build() {
    final client = supabaseClient;
    final currentUser = client?.auth.currentUser;

    if (client != null) {
      final sub = client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null) {
          state = AuthUserState.fromSupabaseUser(session.user);
        } else {
          state = AuthUserState.unauthenticated;
        }
      });
      ref.onDispose(sub.cancel);
    }

    if (currentUser != null) {
      return AuthUserState.fromSupabaseUser(currentUser);
    }
    return AuthUserState.unauthenticated;
  }

  Future<void> signIn(String email, String password) async {
    final client = supabaseClient;
    if (client == null) {
      throw const AuthException('Supabase client is not initialized');
    }

    final res = await client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    final u = res.user;
    if (u != null) {
      state = AuthUserState.fromSupabaseUser(u);
    } else {
      throw const AuthException('Failed to retrieve user session');
    }
  }

  Future<AuthResponse> signUp(String name, String email, String password) async {
    final client = supabaseClient;
    if (client == null) {
      throw const AuthException('Supabase client is not initialized');
    }

    final res = await client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {'name': name.trim()},
    );
    final u = res.user;
    if (u != null && res.session != null) {
      state = AuthUserState.fromSupabaseUser(u);
    }
    return res;
  }

  Future<void> resendConfirmationEmail(String email) async {
    final client = supabaseClient;
    if (client == null) {
      throw const AuthException('Supabase client is not initialized');
    }
    await client.auth.resend(
      type: OtpType.signup,
      email: email.trim().toLowerCase(),
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    final client = supabaseClient;
    if (client == null) {
      throw const AuthException('Supabase client is not initialized');
    }

    final res = await client.auth.updateUser(
      UserAttributes(
        email: email != state.email ? email : null,
        data: {
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      ),
    );
    final u = res.user;
    if (u != null) {
      state = AuthUserState.fromSupabaseUser(u);
    } else {
      state = state.copyWith(
        name: name,
        email: email,
        phone: phone ?? state.phone,
      );
    }
  }

  Future<void> updatePhoto(String? photoUrl) async {
    final client = supabaseClient;
    if (client != null) {
      try {
        await client.auth.updateUser(
          UserAttributes(data: {'avatar_url': photoUrl}),
        );
      } catch (e) {
        debugPrint('Supabase updatePhoto notice: $e');
      }
    }
    if (photoUrl == null) {
      state = state.copyWith(clearPhoto: true);
    } else {
      state = state.copyWith(photoUrl: photoUrl);
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final client = supabaseClient;
    if (client == null) {
      throw const AuthException('Supabase client is not initialized');
    }

    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> deleteAccount() async {
    final client = supabaseClient;
    if (client != null) {
      await client.auth.signOut();
    }
    state = AuthUserState.unauthenticated;
  }

  Future<void> signOut() async {
    final client = supabaseClient;
    if (client != null) {
      await client.auth.signOut();
    }
    state = AuthUserState.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUserState>(
  AuthNotifier.new,
);
