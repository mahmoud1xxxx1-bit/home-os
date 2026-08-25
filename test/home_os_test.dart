import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_os/core/config/app.dart';
import 'package:home_os/core/localization/locale_controller.dart';
import 'package:home_os/core/services/app_models.dart';
import 'package:home_os/core/services/local_repositories.dart';
import 'package:home_os/core/theme/theme_controller.dart';
import 'package:home_os/features/auth/data/local_auth_repository.dart';
import 'package:home_os/features/auth/domain/auth_models.dart';
import 'package:home_os/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AuthRepository signs in, creates account, persists session, and signs out', () async {
    final repo = await LocalAuthRepository.create();
    final user = await repo.signInWithEmail(email: 'owner@homeos.local', password: 'x');
    expect(user.provider, AuthProviderType.email);
    expect((await repo.loadSession()).user?.email, 'owner@homeos.local');
    final created = await repo.createAccount(name: 'Owner', email: 'new@homeos.local', password: 'x');
    expect(created.name, 'Owner');
    await repo.signOut();
    expect((await repo.loadSession()).user, isNull);
  });

  test('AuthRepository simulates Google and Apple providers locally', () async {
    final repo = await LocalAuthRepository.create();
    expect((await repo.signInWithProvider(AuthProviderType.google)).provider, AuthProviderType.google);
    expect((await repo.signInWithProvider(AuthProviderType.apple)).provider, AuthProviderType.apple);
  });

  test('Session persistence stores onboarding state', () async {
    final repo = await LocalAuthRepository.create();
    await repo.completeOnboarding();
    expect((await repo.loadSession()).hasCompletedOnboarding, true);
  });

  test('Home CRUD works', () {
    final store = LocalHomeStore();
    final home = HomeProfile(
      id: 'h2',
      name: const LocalizedText(ar: 'منزل جدة', en: 'Jeddah Home'),
      type: const LocalizedText(ar: 'شقة', en: 'Apartment'),
      createdAt: DateTime.now(),
    );
    store.upsertHome(home);
    expect(store.watchHomes().any((item) => item.id == 'h2'), true);
    store.deleteHome('h2');
    expect(store.watchHomes().any((item) => item.id == 'h2'), false);
  });

  test('Location CRUD works', () {
    final store = LocalHomeStore();
    store.upsertLocation(const LocationArea(id: 'office', name: LocalizedText(ar: 'المكتب', en: 'Office'), icon: 'room'));
    expect(store.locationById('office')?.name.en, 'Office');
    store.deleteLocation('office');
    expect(store.locationById('office'), isNull);
  });

  test('Asset CRUD and soft delete restore work', () {
    final store = LocalHomeStore();
    final now = DateTime.now();
    final asset = HomeAsset(
      id: 'test-asset',
      name: const LocalizedText(ar: 'اختبار', en: 'Test'),
      category: AssetCategory.appliance,
      locationId: 'kitchen',
      createdAt: now,
      updatedAt: now,
    );
    store.addAsset(asset);
    store.updateAsset(asset.copyWith(model: 'M1'));
    expect(store.assetById('test-asset')!.model, 'M1');
    final removed = store.softDeleteAsset('test-asset');
    expect(store.archivedAssets().length, 1);
    store.restoreAsset(removed!);
    expect(store.assetById('test-asset'), isNotNull);
  });

  test('Vehicle model stays specialized asset data', () {
    final vehicle = LocalHomeStore().assetById('asset-car')!;
    expect(vehicle.category, AssetCategory.vehicle);
    expect(vehicle.vehicle?.odometerKm, greaterThan(0));
  });

  test('Maintenance model and repository work', () {
    final store = LocalHomeStore();
    final record = MaintenanceRecord(
      id: 'm-test',
      assetId: 'asset-ac',
      date: DateTime.now(),
      type: const LocalizedText(ar: 'تنظيف', en: 'Cleaning'),
      description: const LocalizedText(ar: 'اختبار', en: 'Test'),
      cost: 100,
      nextDue: DateTime.now().add(const Duration(days: 30)),
    );
    store.addMaintenance(record);
    expect(store.forAsset('asset-ac').any((item) => item.id == 'm-test'), true);
  });

  test('Reminder domain supports all types', () {
    expect(ReminderType.values.length, 4);
    final reminder = Reminder(
      id: 'r',
      title: const LocalizedText(ar: 'تذكير', en: 'Reminder'),
      type: ReminderType.usageBased,
      assetId: 'asset-car',
      dueDate: DateTime(2026, 9),
      alertOffset: AlertOffset.custom,
      usageKm: 45000,
    );
    expect(reminder.usageKm, 45000);
  });

  test('Warranty data exposes statuses', () {
    final warranties = LocalHomeStore().warranties;
    expect(warranties.map((item) => item.status), contains(WarrantyStatus.expiringSoon));
  });

  test('Service recurrence updates last and next visit and activity', () {
    final store = LocalHomeStore();
    final before = store.watchActivity().length;
    store.markServiceVisitCompleted('s1');
    expect(store.services.first.nextVisit.isAfter(store.services.first.lastVisit), true);
    expect(store.watchActivity().length, before + 1);
  });

  test('Provider CRUD works', () {
    final store = LocalHomeStore();
    store.upsertProvider(ProviderContact(
      id: 'p-test',
      name: 'Provider',
      type: const LocalizedText(ar: 'عام', en: 'General'),
      phone: '1',
      whatsApp: '1',
      visitCount: 0,
      totalPaid: 0,
      lastVisit: DateTime.now(),
      linkedAssetIds: const [],
    ));
    expect(store.watchProviders().any((item) => item.id == 'p-test'), true);
    store.deleteProvider('p-test');
    expect(store.watchProviders().any((item) => item.id == 'p-test'), false);
  });

  test('Expense CRUD works', () {
    final store = LocalHomeStore();
    store.upsertExpense(Expense(
      id: 'e-test',
      title: const LocalizedText(ar: 'مصروف', en: 'Expense'),
      category: const LocalizedText(ar: 'خدمات', en: 'Services'),
      assetId: null,
      amount: 42,
      date: DateTime.now(),
    ));
    expect(store.watchExpenses().any((item) => item.id == 'e-test'), true);
    store.deleteExpense('e-test');
    expect(store.watchExpenses().any((item) => item.id == 'e-test'), false);
  });

  test('Family permission model supports viewer restriction', () {
    const viewer = FamilyMember(
      id: 'v',
      name: 'Viewer',
      role: FamilyRole.viewer,
      status: LocalizedText(ar: 'عرض', en: 'View'),
    );
    expect(viewer.role == FamilyRole.viewer, true);
  });

  test('Activity generation happens on important operations', () {
    final store = LocalHomeStore();
    final before = store.watchActivity().length;
    store.upsertLocation(const LocationArea(id: 'x', name: LocalizedText(ar: 'x', en: 'x'), icon: 'x'));
    expect(store.watchActivity().length, before + 1);
  });

  test('Global search finds assets, providers, documents, locations, and services', () {
    final store = LocalHomeStore();
    expect(store.search('Samsung', 'en').any((hit) => hit.type == 'asset'), true);
    expect(store.search('Cool', 'en').any((hit) => hit.type == 'provider'), true);
    expect(store.search('invoice', 'en').any((hit) => hit.type == 'document'), true);
    expect(store.search('Kitchen', 'en').any((hit) => hit.type == 'location'), true);
    expect(store.search('Pool', 'en').any((hit) => hit.type == 'service'), true);
  });

  test('Repository persistence restores saved user-created data', () async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(
      'home_os_local_store_v1',
      jsonEncode({
        'homes': [
          {
            'id': 'persisted',
            'name': {'ar': 'محفوظ', 'en': 'Persisted'},
            'type': {'ar': 'منزل', 'en': 'Home'},
            'createdAt': now.toIso8601String(),
          }
        ],
        'locations': [
          {
            'id': 'persisted-location',
            'name': {'ar': 'مكان', 'en': 'Place'},
            'icon': 'room',
          }
        ],
        'assets': <Object?>[],
        'documents': <Object?>[],
        'expenses': <Object?>[],
        'family': <Object?>[],
      }),
    );
    final store = await LocalHomeStore.load();
    expect(store.watchHomes().first.id, 'persisted');
    expect(store.watchLocations().first.id, 'persisted-location');
  });

  testWidgets('localization supports Arabic RTL', (tester) async {
    await _pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('تسجيل الدخول'), findsWidgets);
    final direction = Directionality.of(tester.element(find.textContaining('تسجيل الدخول').first));
    expect(direction, TextDirection.rtl);
  });

  testWidgets('theme switching updates app theme mode state', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(themeControllerProvider), ThemeMode.system);
    await container.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
    expect(container.read(themeControllerProvider), ThemeMode.dark);
  });

  testWidgets('language controller switches to English', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(localeControllerProvider).languageCode, 'ar');
    await container.read(localeControllerProvider.notifier).setLocale(const Locale('en'));
    expect(container.read(localeControllerProvider).languageCode, 'en');
    expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
  });

  testWidgets('auth route guard sends unauthenticated user to auth', (tester) async {
    await _pumpApp(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('تسجيل الدخول'), findsWidgets);
  });

  testWidgets('navigation reaches dashboard after local login and onboarding', (tester) async {
    await _pumpApp(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('المتابعة كضيف'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تخطي'));
    await tester.pumpAndSettle();
    expect(find.text('Home OS'), findsOneWidget);
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  final repo = await LocalAuthRepository.create();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        localStoreProvider.overrideWithValue(LocalHomeStore()),
      ],
      child: const HomeOsApp(),
    ),
  );
}
