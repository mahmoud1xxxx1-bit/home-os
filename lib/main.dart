import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app.dart';
import 'core/services/local_repositories.dart';
import 'core/services/firestore_home_store.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/local_auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final authRepository = FirebaseAuthRepository(prefs);

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        firestoreStoreProvider.overrideWith((ref) {
          final authState = ref.watch(authControllerProvider);
          final uid = authState.user?.id ?? 'guest';
          final store = FirestoreHomeStore(prefs, uid);
          ref.onDispose(() => store.dispose());
          return store;
        }),
        homeRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        assetRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        maintenanceRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        reminderRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        providerRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        documentRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        expenseRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
        activityRepositoryProvider.overrideWith((ref) => ref.watch(firestoreStoreProvider)),
      ],
      child: const HomeOsApp(),
    ),
  );
}
