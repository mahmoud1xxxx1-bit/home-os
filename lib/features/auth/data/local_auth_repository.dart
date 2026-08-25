import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('AuthRepository must be overridden in main.'),
);

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._prefs);

  static const _userKey = 'home_os_auth_user';
  static const _onboardingKey = 'home_os_onboarding_done';

  final SharedPreferences _prefs;

  static Future<LocalAuthRepository> create() async {
    return LocalAuthRepository(await SharedPreferences.getInstance());
  }

  @override
  Future<AuthState> loadSession() async {
    final raw = _prefs.getString(_userKey);
    final user = raw == null ? null : LocalUser.fromJson(jsonDecode(raw) as Map<String, Object?>);
    return AuthState(
      isLoading: false,
      hasCompletedOnboarding: _prefs.getBool(_onboardingKey) ?? false,
      user: user,
    );
  }

  @override
  Future<LocalUser> signInWithEmail({required String email, required String password}) async {
    final user = LocalUser(
      id: 'local-${email.hashCode.abs()}',
      name: email.split('@').first,
      email: email,
      provider: AuthProviderType.email,
      createdAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<LocalUser> createAccount({required String name, required String email, required String password}) async {
    final user = LocalUser(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim().isEmpty ? email.split('@').first : name.trim(),
      email: email,
      provider: AuthProviderType.email,
      createdAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<LocalUser> signInWithProvider(AuthProviderType provider) async {
    // Real Google/Apple OAuth belongs in FirebaseAuthRepository during the Firebase phase.
    final user = LocalUser(
      id: 'local-${provider.name}',
      name: provider == AuthProviderType.apple ? 'Apple User' : 'Google User',
      email: '${provider.name}@local.homeos',
      provider: provider,
      createdAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> completeOnboarding() => _prefs.setBool(_onboardingKey, true);

  @override
  Future<void> signOut() => _prefs.remove(_userKey);

  @override
  Future<void> deleteAccount() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_onboardingKey);
  }

  Future<void> _saveUser(LocalUser user) => _prefs.setString(_userKey, jsonEncode(user.toJson()));
}
