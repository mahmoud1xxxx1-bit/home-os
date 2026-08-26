import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_auth_repository.dart';
import '../domain/auth_models.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _load();
    return const AuthState(isLoading: true, hasCompletedOnboarding: false);
  }

  Future<void> _load() async {
    final loaded = await ref.read(authRepositoryProvider).loadSession();
    state = loaded;
  }

  Future<void> signInEmail(String email, String password) async {
    final user = await ref.read(authRepositoryProvider).signInWithEmail(email: email, password: password);
    state = state.copyWith(user: user);
  }

  Future<void> createAccount(String name, String email, String password) async {
    final user = await ref.read(authRepositoryProvider).createAccount(name: name, email: email, password: password);
    state = state.copyWith(user: user);
  }

  Future<void> signInProvider(AuthProviderType provider) async {
    final user = await ref.read(authRepositoryProvider).signInWithProvider(provider);
    state = state.copyWith(user: user);
  }

  Future<void> completeOnboarding() async {
    await ref.read(authRepositoryProvider).completeOnboarding();
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  Future<void> signOut() async {
    // Anonymous Firebase users cannot reliably recover the same UID after sign-out.
    // Blocking sign-out here prevents orphaning Home OS data behind an unreachable
    // guest identity. The UI should guide guests to link Google first.
    if (state.user?.provider == AuthProviderType.anonymous) {
      throw StateError('GUEST_ACCOUNT_NOT_LINKED');
    }

    await ref.read(authRepositoryProvider).signOut();
    state = state.copyWith(clearUser: true);
  }

  Future<void> deleteAccount() async {
    await ref.read(authRepositoryProvider).deleteAccount();
    state = const AuthState(isLoading: false, hasCompletedOnboarding: false);
  }
}
