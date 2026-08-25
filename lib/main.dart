import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app.dart';
import 'core/services/firestore_home_store.dart';
import 'core/services/local_repositories.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/local_auth_repository.dart';
import 'features/auth/presentation/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) debugPrintStack(stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Unhandled platform error: $error');
      debugPrintStack(stackTrace: stack);
    }
    return true;
  };

  ErrorWidget.builder = (details) => _SafeErrorFallback(details: details);

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
          ref.onDispose(store.dispose);
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

class _SafeErrorFallback extends StatelessWidget {
  const _SafeErrorFallback({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final isArabic = View.of(context).platformDispatcher.locale.languageCode == 'ar';
    return ColoredBox(
      color: const Color(0xFF101719),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Material(
                  color: const Color(0xFF192326),
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3D40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.home_repair_service_rounded, color: Color(0xFF8AC3CC), size: 32),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          isArabic ? 'تعذر عرض هذا الجزء' : 'We could not display this section',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic
                              ? 'حدث خطأ غير متوقع. بياناتك لم تُحذف. أغلق الصفحة وافتحها مرة أخرى.'
                              : 'Something unexpected happened. Your data was not deleted. Close this page and try again.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFB9C6C8), height: 1.5),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 14),
                          Text(
                            details.exceptionAsString(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF829497), fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
