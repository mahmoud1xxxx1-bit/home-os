import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_models.dart';
import 'repositories.dart';

final firestoreStoreProvider = Provider<FirestoreHomeStore>((ref) => throw UnimplementedError());

class FirestoreHomeStore
    implements
        HomeRepository,
        AssetRepository,
        MaintenanceRepository,
        ReminderRepository,
        ProviderRepository,
        DocumentRepository,
        ExpenseRepository,
        ActivityRepository {
  FirestoreHomeStore(this._prefs, this._uid) {
    _initListeners();
  }

  static const _onboardingKey = 'home_os_onboarding_done';
  final SharedPreferences _prefs;
  final String _uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<HomeProfile> _homes = [];
  List<LocationArea> _locations = [];
  List<HomeAsset> _assets = [];
  List<MaintenanceRecord> _maintenance = [];
  List<Reminder> _reminders = [];
  List<ProviderContact> _providers = [];
  List<ServicePlan> services = [];
  List<Warranty> warranties = [];
  List<HomeDocument> _documents = [];
  List<Expense> _expenses = [];
  List<FamilyMember> family = [];
  List<ActivityEvent> _activity = [];

  List<StreamSubscription> _subs = [];

  void _initListeners() {
    final userDoc = _db.collection('users').doc(_uid);
    
    _subs.add(userDoc.collection('homes').snapshots().listen((snap) {
      _homes = snap.docs.map((d) => _homeFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('locations').snapshots().listen((snap) {
      _locations = snap.docs.map((d) => _locationFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('assets').snapshots().listen((snap) {
      _assets = snap.docs.map((d) => _assetFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('maintenance').snapshots().listen((snap) {
      _maintenance = snap.docs.map((d) => _maintenanceFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('reminders').snapshots().listen((snap) {
      _reminders = snap.docs.map((d) => _reminderFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('providers').snapshots().listen((snap) {
      _providers = snap.docs.map((d) => _providerFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('services').snapshots().listen((snap) {
      services = snap.docs.map((d) => _serviceFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('warranties').snapshots().listen((snap) {
      warranties = snap.docs.map((d) => _warrantyFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('documents').snapshots().listen((snap) {
      _documents = snap.docs.map((d) => _documentFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('expenses').snapshots().listen((snap) {
      _expenses = snap.docs.map((d) => _expenseFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('family').snapshots().listen((snap) {
      family = snap.docs.map((d) => _familyFromJson(d.data(), d.id)).toList();
    }));
    _subs.add(userDoc.collection('activity').orderBy('timestamp', descending: true).snapshots().listen((snap) {
      _activity = snap.docs.map((d) => _activityFromJson(d.data(), d.id)).toList();
    }));
  }

  void dispose() {
    for (var sub in _subs) {
      sub.cancel();
    }
  }

  DocumentReference _doc(String collection, String id) => _db.collection('users').doc(_uid).collection(collection).doc(id);

  @override
  List<HomeProfile> watchHomes() => List.unmodifiable(_homes);

  @override
  List<LocationArea> watchLocations() => List.unmodifiable(_locations);

  @override
  LocationArea? locationById(String id) {
    try { return _locations.firstWhere((l) => l.id == id); } catch (_) { return null; }
  }

  @override
  List<HomeAsset> watchAssets() => List.unmodifiable(_assets.where((asset) => asset.deletedAt == null));

  @override
  HomeAsset? assetById(String id) {
    try { return _assets.firstWhere((a) => a.id == id && a.deletedAt == null); } catch (_) { return null; }
  }

  @override
  void addAsset(HomeAsset asset) {
    _doc('assets', asset.id).set(_assetToJson(asset));
    _log('create', asset.name);
  }

  @override
  void updateAsset(HomeAsset asset) {
    _doc('assets', asset.id).set(_assetToJson(asset), SetOptions(merge: true));
    _log('update', asset.name);
  }

  @override
  HomeAsset? softDeleteAsset(String id) {
    final asset = assetById(id);
    if (asset == null) return null;
    final deleted = asset.copyWith(deletedAt: DateTime.now());
    _doc('assets', id).update({'deletedAt': deleted.deletedAt?.toIso8601String()});
    _log('delete', deleted.name);
    return asset;
  }

  @override
  void restoreAsset(HomeAsset asset) {
    _doc('assets', asset.id).update({'deletedAt': null});
    _log('restore', asset.name);
  }

  @override
  List<MaintenanceRecord> watchMaintenance() => List.unmodifiable(_maintenance);

  @override
  List<MaintenanceRecord> forAsset(String assetId) => List.unmodifiable(_maintenance.where((r) => r.assetId == assetId));

  @override
  void addMaintenance(MaintenanceRecord record) {
    _doc('maintenance', record.id).set(_maintenanceToJson(record));
    _log('maintenance completed', record.description);
  }

  @override
  List<Reminder> watchReminders() => List.unmodifiable(_reminders);

  @override
  void addReminder(Reminder reminder) {
    _doc('reminders', reminder.id).set(_reminderToJson(reminder));
    _log('create', reminder.title);
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
    _doc('activity', activity.id).set(_activityToJson(activity));
  }

  void _log(String type, LocalizedText entity) {
    final act = ActivityEvent(
      id: 'activity-${DateTime.now().microsecondsSinceEpoch}',
      actor: FirebaseAuth.instance.currentUser?.displayName ?? 'User',
      type: LocalizedText(ar: type, en: type),
      entity: entity,
      timestamp: DateTime.now(),
      description: LocalizedText(ar: '$type: ${entity.ar}', en: '$type: ${entity.en}'),
    );
    addActivity(act);
  }

  // --- Helpers ---
  Map<String, Object?> _textToJson(LocalizedText text) => {'ar': text.ar, 'en': text.en};
  LocalizedText _textFromJson(Map<String, dynamic> json) => LocalizedText(ar: json['ar'] as String? ?? '', en: json['en'] as String? ?? '');
  
  Map<String, dynamic> _homeToJson(HomeProfile home) => {'name': _textToJson(home.name), 'type': _textToJson(home.type), 'createdAt': home.createdAt.toIso8601String()};
  HomeProfile _homeFromJson(Map<String, dynamic> json, String id) => HomeProfile(id: id, name: _textFromJson(json['name'] ?? {}), type: _textFromJson(json['type'] ?? {}), createdAt: DateTime.parse(json['createdAt']));

  Map<String, dynamic> _locationToJson(LocationArea loc) => {'name': _textToJson(loc.name), 'icon': loc.icon};
  LocationArea _locationFromJson(Map<String, dynamic> json, String id) => LocationArea(id: id, name: _textFromJson(json['name'] ?? {}), icon: json['icon']);

  Map<String, dynamic> _assetToJson(HomeAsset asset) => {
    'name': _textToJson(asset.name), 'category': asset.category.name, 'locationId': asset.locationId,
    'brand': asset.brand, 'model': asset.model, 'serialNumber': asset.serialNumber,
    'purchaseDate': asset.purchaseDate?.toIso8601String(), 'purchasePrice': asset.purchasePrice,
    'createdAt': asset.createdAt.toIso8601String(), 'updatedAt': asset.updatedAt.toIso8601String(), 'deletedAt': asset.deletedAt?.toIso8601String(),
    'vehicleYear': asset.vehicle?.year, 'vehicleKm': asset.vehicle?.odometerKm,
  };
  HomeAsset _assetFromJson(Map<String, dynamic> json, String id) => HomeAsset(
    id: id, name: _textFromJson(json['name'] ?? {}), category: AssetCategory.values.byName(json['category']),
    locationId: json['locationId'], brand: json['brand'], model: json['model'], serialNumber: json['serialNumber'],
    purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate']) : null, purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['createdAt']), updatedAt: DateTime.parse(json['updatedAt']), deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    vehicle: json['vehicleYear'] != null ? VehicleDetails(make: json['brand'] ?? '', year: json['vehicleYear'], odometerKm: json['vehicleKm'] ?? 0) : null,
  );

  Map<String, dynamic> _maintenanceToJson(MaintenanceRecord rec) => {
    'assetId': rec.assetId, 'date': rec.date.toIso8601String(), 'type': _textToJson(rec.type), 'description': _textToJson(rec.description),
    'cost': rec.cost, 'providerId': rec.providerId, 'phone': rec.phone, 'nextDue': rec.nextDue?.toIso8601String()
  };
  MaintenanceRecord _maintenanceFromJson(Map<String, dynamic> json, String id) => MaintenanceRecord(
    id: id, assetId: json['assetId'], date: DateTime.parse(json['date']), type: _textFromJson(json['type'] ?? {}), description: _textFromJson(json['description'] ?? {}),
    cost: (json['cost'] as num?)?.toDouble() ?? 0.0, providerId: json['providerId'], phone: json['phone'], nextDue: json['nextDue'] != null ? DateTime.parse(json['nextDue']) : null,
  );

  Map<String, dynamic> _reminderToJson(Reminder r) => {'title': _textToJson(r.title), 'type': r.type.name, 'assetId': r.assetId, 'dueDate': r.dueDate.toIso8601String(), 'alertOffset': r.alertOffset.name};
  Reminder _reminderFromJson(Map<String, dynamic> json, String id) => Reminder(id: id, title: _textFromJson(json['title'] ?? {}), type: ReminderType.values.byName(json['type']), assetId: json['assetId'], dueDate: DateTime.parse(json['dueDate']), alertOffset: AlertOffset.values.byName(json['alertOffset']));

  Map<String, dynamic> _providerToJson(ProviderContact p) => {'name': p.name, 'type': _textToJson(p.type), 'phone': p.phone, 'whatsApp': p.whatsApp, 'visitCount': p.visitCount, 'totalPaid': p.totalPaid, 'linkedAssetIds': p.linkedAssetIds, 'lastVisit': p.lastVisit.toIso8601String()};
  ProviderContact _providerFromJson(Map<String, dynamic> json, String id) => ProviderContact(id: id, name: json['name'], type: _textFromJson(json['type'] ?? {}), phone: json['phone'], whatsApp: json['whatsApp'] ?? json['phone'], visitCount: json['visitCount'] ?? 0, totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0, linkedAssetIds: List<String>.from(json['linkedAssetIds'] ?? []), lastVisit: json['lastVisit'] != null ? DateTime.parse(json['lastVisit']) : DateTime.now());

  ServicePlan _serviceFromJson(Map<String, dynamic> json, String id) => ServicePlan(id: id, name: _textFromJson(json['name'] ?? {}), providerId: json['providerId'], phone: json['phone'], frequency: _textFromJson(json['frequency'] ?? {}), cost: (json['cost'] as num?)?.toDouble() ?? 0, lastVisit: DateTime.parse(json['lastVisit']), nextVisit: DateTime.parse(json['nextVisit']));
  Warranty _warrantyFromJson(Map<String, dynamic> json, String id) => Warranty(id: id, assetId: json['assetId'], start: DateTime.parse(json['start']), end: DateTime.parse(json['end']), provider: json['provider'], number: json['number'], status: WarrantyStatus.values.byName(json['status']));

  Map<String, dynamic> _documentToJson(HomeDocument d) => {'title': _textToJson(d.title), 'category': _textToJson(d.category), 'relatedAssetId': d.relatedAssetId, 'createdAt': d.createdAt.toIso8601String(), 'placeholder': d.placeholder};
  HomeDocument _documentFromJson(Map<String, dynamic> json, String id) => HomeDocument(id: id, title: _textFromJson(json['title'] ?? {}), category: _textFromJson(json['category'] ?? {}), relatedAssetId: json['relatedAssetId'], createdAt: DateTime.parse(json['createdAt']), placeholder: json['placeholder']);

  Map<String, dynamic> _expenseToJson(Expense e) => {'title': _textToJson(e.title), 'category': _textToJson(e.category), 'assetId': e.assetId, 'amount': e.amount, 'date': e.date.toIso8601String()};
  Expense _expenseFromJson(Map<String, dynamic> json, String id) => Expense(id: id, title: _textFromJson(json['title'] ?? {}), category: _textFromJson(json['category'] ?? {}), assetId: json['assetId'], amount: (json['amount'] as num).toDouble(), date: DateTime.parse(json['date']));

  FamilyMember _familyFromJson(Map<String, dynamic> json, String id) => FamilyMember(id: id, name: json['name'], role: FamilyRole.values.byName(json['role']), status: _textFromJson(json['status'] ?? {}));

  Map<String, dynamic> _activityToJson(ActivityEvent a) => {'actor': a.actor, 'type': _textToJson(a.type), 'entity': _textToJson(a.entity), 'timestamp': a.timestamp.toIso8601String(), 'description': _textToJson(a.description)};
  ActivityEvent _activityFromJson(Map<String, dynamic> json, String id) => ActivityEvent(id: id, actor: json['actor'], type: _textFromJson(json['type'] ?? {}), entity: _textFromJson(json['entity'] ?? {}), timestamp: DateTime.parse(json['timestamp']), description: _textFromJson(json['description'] ?? {}));
}
