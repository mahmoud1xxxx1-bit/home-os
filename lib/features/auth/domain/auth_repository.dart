import 'auth_models.dart';

abstract interface class AuthRepository {
  Future<AuthState> loadSession();
  Future<LocalUser> signInWithEmail({required String email, required String password});
  Future<LocalUser> createAccount({required String name, required String email, required String password});
  Future<LocalUser> signInWithProvider(AuthProviderType provider);
  Future<void> sendPasswordReset(String email);
  Future<void> completeOnboarding();
  Future<void> signOut();
  Future<void> deleteAccount();
}
