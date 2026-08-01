import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../features/banking/data/banking_repository.dart';
import '../../features/profile/domain/profile.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final apiProvider = Provider((ref) => ApiClient(ref.read(tokenStoreProvider)));
final repositoryProvider = Provider(
  (ref) => BankingRepository(ref.read(apiProvider)),
);
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final data = await ref.read(repositoryProvider).profile();
  return UserProfile.fromJson(data);
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;
  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

enum AuthStatus { loading, signedOut, signedIn }

class AuthState {
  const AuthState(this.status, [this.user]);
  final AuthStatus status;
  final Map<String, dynamic>? user;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(restore);
    return const AuthState(AuthStatus.loading);
  }

  Future<void> restore() async {
    if (await ref.read(tokenStoreProvider).read() == null) {
      state = const AuthState(AuthStatus.signedOut);
      return;
    }
    try {
      state = AuthState(
        AuthStatus.signedIn,
        await ref.read(repositoryProvider).profile(),
      );
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();
      state = const AuthState(AuthStatus.signedOut);
    }
  }

  Future<void> login(String email, String password) async {
    final result = await ref
        .read(repositoryProvider)
        .login(email.trim(), password);
    await ref.read(tokenStoreProvider).write(result['accessToken'] as String);
    state = AuthState(
      AuthStatus.signedIn,
      Map<String, dynamic>.from(result['user'] as Map),
    );
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AuthState(AuthStatus.signedOut);
  }
}
