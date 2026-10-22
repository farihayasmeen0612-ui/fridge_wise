import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUserState {
  const AuthUserState({
    this.isAuthenticated = true,
    this.email = 'user@smartfridge.local',
    this.name = 'Alex',
  });

  final bool isAuthenticated;
  final String email;
  final String name;

  AuthUserState copyWith({
    bool? isAuthenticated,
    String? email,
    String? name,
  }) {
    return AuthUserState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }
}

class AuthNotifier extends Notifier<AuthUserState> {
  @override
  AuthUserState build() {
    return const AuthUserState(
      isAuthenticated: true,
      email: 'user@smartfridge.local',
      name: 'Alex',
    );
  }

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate auth latency
    state = state.copyWith(
      isAuthenticated: true,
      email: email,
      name: email.split('@').first,
    );
  }

  Future<void> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isAuthenticated: true,
      email: email,
      name: name,
    );
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUserState>(
  AuthNotifier.new,
);
