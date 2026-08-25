import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_models.dart';
import 'repositories.dart';

final localStoreProvider = Provider<LocalHomeStore>((ref) => LocalHomeStore());

final homeRepositoryProvider = Provider<HomeRepository>((ref) => ref.watch(localStoreProvider));
final assetRepositoryProvider = Provider<AssetRepository>((ref) => ref.watch(localStoreProvider));
final maintenanceRepositoryProvider =
    Provider<MaintenanceRepository>((ref) => ref.watch(localStoreProvider));
final reminderRepositoryProvider =
    Provider<ReminderRepository>((ref) => ref.watch(localStoreProvider));
final providerRepositoryProvider =
    Provider<ProviderRepository>((ref) => ref.watch(localStoreProvider));
final documentRepositoryProvider =
    Provider<DocumentRepository>((ref) => ref.watch(localStoreProvider));
final expenseRepositoryProvider =
    Provider<ExpenseRepository>((ref) => ref.watch(localStoreProvider));
final activityRepositoryProvider =
    Provider<ActivityRepository>((ref) => ref.watch(localStoreProvider));

final assetsProvider = Provider<List<HomeAsset>>(
  (ref) => ref.watch(assetRepositoryProvider).watchAssets(),
);
final remindersProvider = Provider<List<Reminder>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchReminders(),
);
final maintenanceProvider = Provider<List<MaintenanceRecord>>(
  (ref) => ref.watch(maintenanceRepositoryProvider).watchMaintenance(),
);
final providersProvider = Provider<List<ProviderContact>>(
  (ref) => ref.watch(providerRepositoryProvider).watchProviders(),
);
final documentsProvider = Provider<List<HomeDocument>>(
  (ref) => ref.watch(documentRepositoryProvider).watchDocuments(),
);
final expensesProvider = Provider<List<Expense>>(
  (ref) => ref.watch(expenseRepositoryProvider).watchExpenses(),
);
final activityProvider = Provider<List<ActivityEvent>>(
  (ref) => ref.watch(activityRepositoryProvider).watchActivity(),
);

class LocalHomeStore
    implements
        HomeRepository,
        AssetRepository,
        MaintenanceRepository,
        ReminderRepository,
        ProviderRepository,
        DocumentRepository,
        ExpenseRepository,
        ActivityRepository {
  LocalHomeStore([this._prefs]);

  static const _stateKey = 'home_os_local_store_v1';

  final SharedPreferences? _prefs;

  static Future<LocalHomeStore> load() async {
    final store = LocalHomeStore(await SharedPreferences.getInstance());
    store._restore();
    return store;
  }

  final _now = DateTime.now();
  final List<HomeProfile> _homes = [
    HomeProfile(
      id: 'home-riyadh',
      name: LocalizedText(ar: 'منزل الرياض', en: 'Riyadh Home'),
      type: LocalizedText(ar: 'فيلا', en: 'Villa'),
      createdAt: DateTime(2026, 8, 1),
    ),
  ];

  final List<LocationArea> _locations = [
    LocationArea(id: 'majlis', name: LocalizedText(ar: 'المجلس', en: 'Majlis'), icon: 'weekend'),
    LocationArea(id: 'kitchen', name: LocalizedText(ar: 'المطبخ', en: 'Kitchen'), icon: 'kitchen'),
    LocationArea(id: 'garage', name: LocalizedText(ar: 'الكراج', en: 'Garage'), icon: 'garage'),
    LocationArea(id: 'garden', name: LocalizedText(ar: 'الحديقة', en: 'Garden'), icon: 'yard'),
    LocationArea(id: 'pool', name: LocalizedText(ar: 'المسبح', en: 'Pool'), icon: 'pool'),
    LocationArea(id: 'roof', name: LocalizedText(ar: 'السطح', en: 'Roof'), icon: 'roofing'),
  ];

  late final List<HomeAsset> _assets = [
    HomeAsset(
      id: 'asset-ac',
      name: const LocalizedText(ar: 'مكيف المجلس', en: 'Majlis AC'),
      category: AssetCategory.hvac,
      locationId: 'majlis',
      brand: 'Gree',
      model: 'Split Pro 24K',
      serialNumber: 'GR-24-8891',
      purchaseDate: DateTime(2024, 4, 16),
      purchasePrice: 3200,
      installationDate: DateTime(2024, 4, 18),
      notes: const LocalizedText(ar: 'تنظيف الفلتر كل شهرين.', en: 'Clean filter every two months.'),
      createdAt: DateTime(2024, 4, 16),
      updatedAt: _now,
    ),
    HomeAsset(
      id: 'asset-fridge',
      name: const LocalizedText(ar: 'ثلاجة Samsung', en: 'Samsung Refrigerator'),
      category: AssetCategory.kitchen,
      locationId: 'kitchen',
      brand: 'Samsung',
      model: 'Bespoke 520L',
      serialNumber: 'SMG-520-7782',
      purchaseDate: DateTime(2025, 2, 2),
      purchasePrice: 5600,
      createdAt: DateTime(2025, 2, 2),
      updatedAt: _now,
    ),
    HomeAsset(
      id: 'asset-coffee',
      name: const LocalizedText(ar: 'آلة قهوة', en: 'Coffee Machine'),
      category: AssetCategory.appliance,
      locationId: 'kitchen',
      brand: 'DeLonghi',
      model: 'Dinamica',
      purchaseDate: DateTime(2025, 9, 1),
      purchasePrice: 2800,
      createdAt: DateTime(2025, 9, 1),
      updatedAt: _now,
    ),
    HomeAsset(
      id: 'asset-car',
      name: const LocalizedText(ar: 'Toyota Land Cruiser', en: 'Toyota Land Cruiser'),
      category: AssetCategory.vehicle,
      locationId: 'garage',
      brand: 'Toyota',
      model: 'Land Cruiser',
      purchaseDate: DateTime(2023, 7, 10),
      purchasePrice: 310000,
      createdAt: DateTime(2023, 7, 10),
      updatedAt: _now,
      vehicle: VehicleDetails(
        make: 'Toyota',
        year: 2023,
        plateNumber: 'أ ب ج 4821',
        vin: 'JTMCY7AJXN4123456',
        odometerKm: 41800,
        insuranceExpiry: _now.add(const Duration(days: 24)),
        inspectionExpiry: _now.add(const Duration(days: 61)),
        warrantyExpiry: _now.add(const Duration(days: 300)),
        lastMaintenance: _now.subtract(const Duration(days: 42)),
        nextDueDate: _now.add(const Duration(days: 35)),
        nextDueKm: 45000,
      ),
    ),
  ];

  late final List<MaintenanceRecord> _maintenance = [
    MaintenanceRecord(
      id: 'm1',
      assetId: 'asset-ac',
      date: _now.subtract(const Duration(days: 3)),
      type: const LocalizedText(ar: 'تنظيف', en: 'Cleaning'),
      description: const LocalizedText(ar: 'تنظيف فلاتر ومراجعة التبريد', en: 'Filter cleaning and cooling check'),
      cost: 180,
      providerId: 'p1',
      phone: '+966500000001',
      serviceWarrantyUntil: _now.add(const Duration(days: 60)),
      nextDue: _now.add(const Duration(days: 2)),
      beforeImagePlaceholder: 'before-ac',
      afterImagePlaceholder: 'after-ac',
      invoicePlaceholder: 'invoice-ac',
    ),
    MaintenanceRecord(
      id: 'm2',
      assetId: 'asset-car',
      date: _now.subtract(const Duration(days: 42)),
      type: const LocalizedText(ar: 'صيانة دورية', en: 'Periodic service'),
      description: const LocalizedText(ar: 'تغيير زيت وفلاتر', en: 'Oil and filter change'),
      cost: 950,
      providerId: 'p3',
      phone: '+966500000003',
      nextDue: _now.add(const Duration(days: 35)),
      invoicePlaceholder: 'invoice-car',
    ),
  ];

  late final List<Reminder> _reminders = [
    Reminder(
      id: 'r1',
      title: const LocalizedText(ar: 'صيانة مكيف المجلس', en: 'Majlis AC maintenance'),
      type: ReminderType.recurring,
      assetId: 'asset-ac',
      dueDate: _now.add(const Duration(days: 2)),
      alertOffset: AlertOffset.threeDays,
      repeatEveryDays: 90,
    ),
    Reminder(
      id: 'r2',
      title: const LocalizedText(ar: 'انتهاء ضمان الغسالة', en: 'Washer warranty expiry'),
      type: ReminderType.expiry,
      assetId: null,
      dueDate: _now.add(const Duration(days: 12)),
      alertOffset: AlertOffset.sevenDays,
    ),
    Reminder(
      id: 'r3',
      title: const LocalizedText(ar: 'تأمين السيارة', en: 'Vehicle insurance'),
      type: ReminderType.expiry,
      assetId: 'asset-car',
      dueDate: _now.add(const Duration(days: 24)),
      alertOffset: AlertOffset.thirtyDays,
    ),
    Reminder(
      id: 'r4',
      title: const LocalizedText(ar: 'صيانة السيارة عند 45000 كم', en: 'Vehicle service at 45,000 km'),
      type: ReminderType.usageBased,
      assetId: 'asset-car',
      dueDate: _now.add(const Duration(days: 35)),
      alertOffset: AlertOffset.custom,
      usageKm: 45000,
    ),
  ];

  late final List<ProviderContact> _providers = [
    ProviderContact(
      id: 'p1',
      name: 'CoolCare',
      type: const LocalizedText(ar: 'تكييف', en: 'HVAC'),
      phone: '+966500000001',
      whatsApp: '+966500000001',
      visitCount: 4,
      totalPaid: 920,
      lastVisit: _now.subtract(const Duration(days: 3)),
      linkedAssetIds: const ['asset-ac'],
    ),
    ProviderContact(
      id: 'p2',
      name: 'Green Hands',
      type: const LocalizedText(ar: 'حديقة', en: 'Garden'),
      phone: '+966500000002',
      whatsApp: '+966500000002',
      visitCount: 9,
      totalPaid: 1800,
      lastVisit: _now.subtract(const Duration(days: 6)),
      linkedAssetIds: const [],
    ),
    ProviderContact(
      id: 'p3',
      name: 'Toyota Service',
      type: const LocalizedText(ar: 'سيارات', en: 'Vehicles'),
      phone: '+966500000003',
      whatsApp: '+966500000003',
      visitCount: 3,
      totalPaid: 2850,
      lastVisit: _now.subtract(const Duration(days: 42)),
      linkedAssetIds: const ['asset-car'],
    ),
  ];

  late final List<ServicePlan> services = [
    ServicePlan(
      id: 's1',
      name: const LocalizedText(ar: 'عامل الحديقة', en: 'Garden worker'),
      providerId: 'p2',
      phone: '+966500000002',
      frequency: const LocalizedText(ar: 'أسبوعيًا', en: 'Weekly'),
      cost: 200,
      lastVisit: _now.subtract(const Duration(days: 6)),
      nextVisit: _now.add(const Duration(days: 1)),
    ),
    ServicePlan(
      id: 's2',
      name: const LocalizedText(ar: 'تنظيف المسبح', en: 'Pool cleaning'),
      providerId: 'p2',
      phone: '+966500000002',
      frequency: const LocalizedText(ar: 'كل أسبوعين', en: 'Every two weeks'),
      cost: 260,
      lastVisit: _now.subtract(const Duration(days: 10)),
      nextVisit: _now.add(const Duration(days: 4)),
    ),
  ];

  late final List<Warranty> warranties = [
    Warranty(
      id: 'w1',
      assetId: 'asset-fridge',
      start: DateTime(2025, 2, 2),
      end: _now.add(const Duration(days: 120)),
      provider: 'Samsung',
      number: 'SAM-W-8821',
      status: WarrantyStatus.valid,
      documentPlaceholder: 'samsung-warranty',
    ),
    Warranty(
      id: 'w2',
      assetId: 'asset-ac',
      start: DateTime(2024, 4, 16),
      end: _now.add(const Duration(days: 12)),
      provider: 'Gree',
      number: 'GRE-AC-1001',
      status: WarrantyStatus.expiringSoon,
      documentPlaceholder: 'gree-warranty',
    ),
  ];

  late final List<HomeDocument> _documents = [
    HomeDocument(
      id: 'd1',
      title: const LocalizedText(ar: 'فاتورة مكيف المجلس', en: 'Majlis AC invoice'),
      category: const LocalizedText(ar: 'فواتير', en: 'Invoices'),
      relatedAssetId: 'asset-ac',
      createdAt: DateTime(2024, 4, 16),
      placeholder: 'invoice metadata only',
    ),
    HomeDocument(
      id: 'd2',
      title: const LocalizedText(ar: 'وثيقة تأمين السيارة', en: 'Vehicle insurance policy'),
      category: const LocalizedText(ar: 'تأمين', en: 'Insurance'),
      relatedAssetId: 'asset-car',
      createdAt: _now.subtract(const Duration(days: 300)),
      placeholder: 'insurance metadata only',
    ),
  ];

  late final List<Expense> _expenses = [
    Expense(
      id: 'e1',
      title: const LocalizedText(ar: 'تنظيف مكيف', en: 'AC cleaning'),
      category: const LocalizedText(ar: 'صيانة', en: 'Maintenance'),
      assetId: 'asset-ac',
      amount: 180,
      date: _now.subtract(const Duration(days: 3)),
    ),
    Expense(
      id: 'e2',
      title: const LocalizedText(ar: 'عامل الحديقة', en: 'Garden worker'),
      category: const LocalizedText(ar: 'حديقة', en: 'Garden'),
      assetId: null,
      amount: 200,
      date: _now.subtract(const Duration(days: 6)),
    ),
    Expense(
      id: 'e3',
      title: const LocalizedText(ar: 'صيانة السيارة', en: 'Vehicle service'),
      category: const LocalizedText(ar: 'سيارات', en: 'Vehicles'),
      assetId: 'asset-car',
      amount: 950,
      date: _now.subtract(const Duration(days: 42)),
    ),
  ];

  late final List<FamilyMember> family = [
    FamilyMember(id: 'f1', name: 'Abdullah', role: FamilyRole.owner, status: LocalizedText(ar: 'مالك المنزل', en: 'Home owner')),
    FamilyMember(id: 'f2', name: 'Sara', role: FamilyRole.admin, status: LocalizedText(ar: 'تدير المستندات', en: 'Manages documents')),
    FamilyMember(id: 'f3', name: 'Noura', role: FamilyRole.viewer, status: LocalizedText(ar: 'عرض فقط', en: 'View only')),
  ];

  late final List<ActivityEvent> _activity = [
    ActivityEvent(
      id: 'a1',
      actor: 'Abdullah',
      type: const LocalizedText(ar: 'صيانة', en: 'Maintenance'),
      entity: const LocalizedText(ar: 'مكيف المجلس', en: 'Majlis AC'),
      timestamp: _now.subtract(const Duration(days: 3)),
      description: const LocalizedText(ar: 'تمت صيانة مكيف المجلس', en: 'Majlis AC was serviced'),
    ),
    ActivityEvent(
      id: 'a2',
      actor: 'Sara',
      type: const LocalizedText(ar: 'مستند', en: 'Document'),
      entity: const LocalizedText(ar: 'فاتورة', en: 'Invoice'),
      timestamp: _now.subtract(const Duration(days: 5)),
      description: const LocalizedText(ar: 'تمت إضافة فاتورة', en: 'An invoice was added'),
    ),
    ActivityEvent(
      id: 'a3',
      actor: 'Home OS',
      type: const LocalizedText(ar: 'تذكير', en: 'Reminder'),
      entity: const LocalizedText(ar: 'صيانة', en: 'Maintenance'),
      timestamp: _now.subtract(const Duration(days: 8)),
      description: const LocalizedText(ar: 'تم تعديل موعد صيانة', en: 'A maintenance date was changed'),
    ),
  ];

  @override
  List<HomeProfile> watchHomes() => List.unmodifiable(_homes);

  @override
  List<LocationArea> watchLocations() => List.unmodifiable(_locations);

  @override
  LocationArea? locationById(String id) {
    for (final location in _locations) {
      if (location.id == id) return location;
    }
    return null;
  }

  @override
  List<HomeAsset> watchAssets() => List.unmodifiable(_assets.where((asset) => asset.deletedAt == null));

  @override
  HomeAsset? assetById(String id) {
    for (final asset in _assets) {
      if (asset.id == id && asset.deletedAt == null) return asset;
    }
    return null;
  }

  @override
  void addAsset(HomeAsset asset) {
    _assets.add(asset);
    _log('create', asset.name);
    _save();
  }

  @override
  void updateAsset(HomeAsset asset) {
    final index = _assets.indexWhere((item) => item.id == asset.id);
    if (index >= 0) _assets[index] = asset;
    _log('update', asset.name);
    _save();
  }

  @override
  HomeAsset? softDeleteAsset(String id) {
    final index = _assets.indexWhere((item) => item.id == id);
    if (index == -1) return null;
    final deleted = _assets[index].copyWith(deletedAt: DateTime.now());
    _assets[index] = deleted;
    _log('delete', deleted.name);
    _save();
    return _assets[index].copyWith(deletedAt: null);
  }

  @override
  void restoreAsset(HomeAsset asset) {
    final index = _assets.indexWhere((item) => item.id == asset.id);
    if (index >= 0) {
      _assets[index] = asset.copyWith(deletedAt: null);
    } else {
      _assets.add(asset.copyWith(deletedAt: null));
    }
    _log('restore', asset.name);
    _save();
  }

  @override
  List<MaintenanceRecord> watchMaintenance() => List.unmodifiable(_maintenance);

  @override
  List<MaintenanceRecord> forAsset(String assetId) =>
      List.unmodifiable(_maintenance.where((record) => record.assetId == assetId));

  @override
  void addMaintenance(MaintenanceRecord record) {
    _maintenance.add(record);
    _log('maintenance completed', record.description);
    _save();
  }

  @override
  List<Reminder> watchReminders() => List.unmodifiable(_reminders);

  @override
  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    _log('create', reminder.title);
    _save();
  }

  @override
  List<ProviderContact> watchProviders() => List.unmodifiable(_providers);

  @override
  List<HomeDocument> watchDocuments() => List.unmodifiable(_documents);

  @override
  List<Expense> watchExpenses() => List.unmodifiable(_expenses);

  @override
  List<ActivityEvent> watchActivity() => List.unmodifiable(_activity);

  @override
  void addActivity(ActivityEvent activity) {
    _activity.insert(0, activity);
    _save();
  }

  List<HomeAsset> archivedAssets() => List.unmodifiable(_assets.where((asset) => asset.deletedAt != null));

  void upsertHome(HomeProfile home) {
    final index = _homes.indexWhere((item) => item.id == home.id);
    if (index >= 0) {
      _homes[index] = home;
    } else {
      _homes.add(home);
    }
    _log('update', home.name);
    _save();
  }

  void deleteHome(String id) {
    _homes.removeWhere((home) => home.id == id);
    _log('delete', const LocalizedText(ar: 'منزل', en: 'Home'));
    _save();
  }

  void upsertLocation(LocationArea location) {
    final index = _locations.indexWhere((item) => item.id == location.id);
    if (index >= 0) {
      _locations[index] = location;
    } else {
      _locations.add(location);
    }
    _log('update', location.name);
    _save();
  }

  void deleteLocation(String id) {
    _locations.removeWhere((location) => location.id == id);
    _log('delete', const LocalizedText(ar: 'مكان', en: 'Location'));
    _save();
  }

  void upsertProvider(ProviderContact provider) {
    final index = _providers.indexWhere((item) => item.id == provider.id);
    if (index >= 0) {
      _providers[index] = provider;
    } else {
      _providers.add(provider);
    }
    _log('update', LocalizedText(ar: provider.name, en: provider.name));
    _save();
  }

  void deleteProvider(String id) {
    _providers.removeWhere((provider) => provider.id == id);
    _log('delete', const LocalizedText(ar: 'مقدم خدمة', en: 'Provider'));
    _save();
  }

  void upsertDocument(HomeDocument document) {
    final index = _documents.indexWhere((item) => item.id == document.id);
    if (index >= 0) {
      _documents[index] = document;
    } else {
      _documents.add(document);
    }
    _log('update', document.title);
    _save();
  }

  void deleteDocument(String id) {
    _documents.removeWhere((document) => document.id == id);
    _log('delete', const LocalizedText(ar: 'مستند', en: 'Document'));
    _save();
  }

  void upsertExpense(Expense expense) {
    final index = _expenses.indexWhere((item) => item.id == expense.id);
    if (index >= 0) {
      _expenses[index] = expense;
    } else {
      _expenses.add(expense);
    }
    _log('expense added', expense.title);
    _save();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    _log('delete', const LocalizedText(ar: 'مصروف', en: 'Expense'));
    _save();
  }

  void upsertFamilyMember(FamilyMember member) {
    final index = family.indexWhere((item) => item.id == member.id);
    if (index >= 0) {
      family[index] = member;
    } else {
      family.add(member);
    }
    _log('member change', LocalizedText(ar: member.name, en: member.name));
    _save();
  }

  void removeFamilyMember(String id) {
    family.removeWhere((member) => member.id == id);
    _log('member change', const LocalizedText(ar: 'عضو', en: 'Member'));
    _save();
  }

  void markServiceVisitCompleted(String id) {
    final index = services.indexWhere((service) => service.id == id);
    if (index == -1) return;
    final current = services[index];
    final now = DateTime.now();
    services[index] = ServicePlan(
      id: current.id,
      name: current.name,
      providerId: current.providerId,
      phone: current.phone,
      frequency: current.frequency,
      cost: current.cost,
      lastVisit: now,
      nextVisit: now.add(const Duration(days: 7)),
      notes: current.notes,
    );
    _log('service completed', current.name);
    _save();
  }

  List<SearchHit> search(String query, String languageCode) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return const [];
    bool match(String value) => value.toLowerCase().contains(term);
    final hits = <SearchHit>[];
    for (final asset in watchAssets()) {
      if (match(asset.name.value(languageCode)) || match(asset.brand ?? '') || match(asset.model ?? '')) {
        hits.add(SearchHit('asset', asset.id, asset.name));
      }
    }
    for (final location in _locations) {
      if (match(location.name.value(languageCode))) hits.add(SearchHit('location', location.id, location.name));
    }
    for (final provider in _providers) {
      if (match(provider.name) || match(provider.type.value(languageCode))) {
        hits.add(SearchHit('provider', provider.id, LocalizedText(ar: provider.name, en: provider.name)));
      }
    }
    for (final document in _documents) {
      if (match(document.title.value(languageCode)) || match(document.category.value(languageCode))) {
        hits.add(SearchHit('document', document.id, document.title));
      }
    }
    for (final service in services) {
      if (match(service.name.value(languageCode))) hits.add(SearchHit('service', service.id, service.name));
    }
    return hits;
  }

  void _log(String type, LocalizedText entity) {
    _activity.insert(
      0,
      ActivityEvent(
        id: 'activity-${DateTime.now().microsecondsSinceEpoch}',
        actor: 'Local User',
        type: LocalizedText(ar: type, en: type),
        entity: entity,
        timestamp: DateTime.now(),
        description: LocalizedText(ar: '$type: ${entity.ar}', en: '$type: ${entity.en}'),
      ),
    );
  }

  void _save() {
    final prefs = _prefs;
    if (prefs == null) return;
    prefs.setString(
      _stateKey,
      jsonEncode({
        'homes': _homes.map(_homeToJson).toList(),
        'locations': _locations.map(_locationToJson).toList(),
        'assets': _assets.map(_assetToJson).toList(),
        'documents': _documents.map(_documentToJson).toList(),
        'expenses': _expenses.map(_expenseToJson).toList(),
        'family': family.map(_familyToJson).toList(),
      }),
    );
  }

  void _restore() {
    final raw = _prefs?.getString(_stateKey);
    if (raw == null) return;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _homes
      ..clear()
      ..addAll((json['homes'] as List<dynamic>).map((item) => _homeFromJson(item as Map<String, dynamic>)));
    _locations
      ..clear()
      ..addAll((json['locations'] as List<dynamic>).map((item) => _locationFromJson(item as Map<String, dynamic>)));
    _assets
      ..clear()
      ..addAll((json['assets'] as List<dynamic>).map((item) => _assetFromJson(item as Map<String, dynamic>)));
    _documents
      ..clear()
      ..addAll((json['documents'] as List<dynamic>).map((item) => _documentFromJson(item as Map<String, dynamic>)));
    _expenses
      ..clear()
      ..addAll((json['expenses'] as List<dynamic>).map((item) => _expenseFromJson(item as Map<String, dynamic>)));
    family
      ..clear()
      ..addAll((json['family'] as List<dynamic>).map((item) => _familyFromJson(item as Map<String, dynamic>)));
  }
}

class SearchHit {
  const SearchHit(this.type, this.id, this.title);

  final String type;
  final String id;
  final LocalizedText title;
}

Map<String, Object?> _textToJson(LocalizedText text) => {'ar': text.ar, 'en': text.en};
LocalizedText _textFromJson(Map<String, dynamic> json) => LocalizedText(ar: json['ar'] as String, en: json['en'] as String);
String? _dateToJson(DateTime? date) => date?.toIso8601String();
DateTime? _dateFromJson(Object? value) => value == null ? null : DateTime.parse(value as String);

Map<String, Object?> _homeToJson(HomeProfile home) => {
      'id': home.id,
      'name': _textToJson(home.name),
      'type': _textToJson(home.type),
      'createdAt': home.createdAt.toIso8601String(),
    };
HomeProfile _homeFromJson(Map<String, dynamic> json) => HomeProfile(
      id: json['id'] as String,
      name: _textFromJson(json['name'] as Map<String, dynamic>),
      type: _textFromJson(json['type'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, Object?> _locationToJson(LocationArea location) => {
      'id': location.id,
      'name': _textToJson(location.name),
      'icon': location.icon,
    };
LocationArea _locationFromJson(Map<String, dynamic> json) => LocationArea(
      id: json['id'] as String,
      name: _textFromJson(json['name'] as Map<String, dynamic>),
      icon: json['icon'] as String,
    );

Map<String, Object?> _assetToJson(HomeAsset asset) => {
      'id': asset.id,
      'name': _textToJson(asset.name),
      'category': asset.category.name,
      'locationId': asset.locationId,
      'brand': asset.brand,
      'model': asset.model,
      'serialNumber': asset.serialNumber,
      'purchaseDate': _dateToJson(asset.purchaseDate),
      'purchasePrice': asset.purchasePrice,
      'createdAt': asset.createdAt.toIso8601String(),
      'updatedAt': asset.updatedAt.toIso8601String(),
      'deletedAt': _dateToJson(asset.deletedAt),
      'vehicleYear': asset.vehicle?.year,
      'vehicleKm': asset.vehicle?.odometerKm,
    };
HomeAsset _assetFromJson(Map<String, dynamic> json) => HomeAsset(
      id: json['id'] as String,
      name: _textFromJson(json['name'] as Map<String, dynamic>),
      category: AssetCategory.values.byName(json['category'] as String),
      locationId: json['locationId'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      serialNumber: json['serialNumber'] as String?,
      purchaseDate: _dateFromJson(json['purchaseDate']),
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: _dateFromJson(json['deletedAt']),
      vehicle: json['vehicleYear'] == null
          ? null
          : VehicleDetails(
              make: json['brand'] as String? ?? '',
              year: json['vehicleYear'] as int,
              odometerKm: json['vehicleKm'] as int? ?? 0,
            ),
    );

Map<String, Object?> _documentToJson(HomeDocument document) => {
      'id': document.id,
      'title': _textToJson(document.title),
      'category': _textToJson(document.category),
      'relatedAssetId': document.relatedAssetId,
      'createdAt': document.createdAt.toIso8601String(),
      'placeholder': document.placeholder,
    };
HomeDocument _documentFromJson(Map<String, dynamic> json) => HomeDocument(
      id: json['id'] as String,
      title: _textFromJson(json['title'] as Map<String, dynamic>),
      category: _textFromJson(json['category'] as Map<String, dynamic>),
      relatedAssetId: json['relatedAssetId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      placeholder: json['placeholder'] as String,
    );

Map<String, Object?> _expenseToJson(Expense expense) => {
      'id': expense.id,
      'title': _textToJson(expense.title),
      'category': _textToJson(expense.category),
      'assetId': expense.assetId,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
    };
Expense _expenseFromJson(Map<String, dynamic> json) => Expense(
      id: json['id'] as String,
      title: _textFromJson(json['title'] as Map<String, dynamic>),
      category: _textFromJson(json['category'] as Map<String, dynamic>),
      assetId: json['assetId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, Object?> _familyToJson(FamilyMember member) => {
      'id': member.id,
      'name': member.name,
      'role': member.role.name,
      'status': _textToJson(member.status),
    };
FamilyMember _familyFromJson(Map<String, dynamic> json) => FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      role: FamilyRole.values.byName(json['role'] as String),
      status: _textFromJson(json['status'] as Map<String, dynamic>),
    );
