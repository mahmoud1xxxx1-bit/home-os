import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._prefs);

  static const _onboardingKey = 'home_os_onboarding_done';
  final SharedPreferences _prefs;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<AuthState> loadSession() async {
    final fbUser = _auth.currentUser;
    return AuthState(
      isLoading: false,
      hasCompletedOnboarding: _prefs.getBool(_onboardingKey) ?? false,
      user: fbUser != null ? _mapUser(fbUser) : null,
    );
  }

  @override
  Future<LocalUser> signInWithEmail({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return _mapUser(cred.user!);
  }

  @override
  Future<LocalUser> createAccount({required String name, required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(name);
    return _mapUser(cred.user!);
  }

  @override
  Future<LocalUser> signInWithProvider(AuthProviderType provider) async {
    if (provider == AuthProviderType.google) {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign In aborted');
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      return _mapUser(cred.user!);
    }

    final cred = await _auth.signInAnonymously();
    return _mapUser(cred.user!);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> completeOnboarding() => _prefs.setBool(_onboardingKey, true);

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
    await _prefs.remove(_onboardingKey);
  }

  LocalUser _mapUser(fb.User fbUser) {
    final provider = fbUser.isAnonymous
        ? AuthProviderType.anonymous
        : fbUser.providerData.any((item) => item.providerId == 'google.com')
            ? AuthProviderType.google
            : AuthProviderType.email;

    return LocalUser(
      id: fbUser.uid,
      name: fbUser.displayName ?? (fbUser.isAnonymous ? 'Guest' : 'User'),
      email: fbUser.email ?? '',
      provider: provider,
      createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
    );
  }
}
