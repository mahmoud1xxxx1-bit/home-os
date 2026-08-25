import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/auth_models.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._prefs);

  static const _onboardingKey = 'home_os_onboarding_done';
  static const _userCollections = <String>[
    'homes',
    'locations',
    'assets',
    'maintenance',
    'reminders',
    'providers',
    'services',
    'warranties',
    'documents',
    'expenses',
    'family',
    'activity',
  ];

  final SharedPreferences _prefs;
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _db.collection('users').doc(user.uid);
    for (final collection in _userCollections) {
      await _deleteCollection(userRef.collection(collection));
    }
    await userRef.delete();
    await user.delete();
    await _prefs.remove(_onboardingKey);
  }

  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> collection) async {
    while (true) {
      final snapshot = await collection.limit(200).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _db.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < 200) return;
    }
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
