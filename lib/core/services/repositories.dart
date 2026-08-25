import 'app_models.dart';

abstract interface class HomeRepository {
  List<HomeProfile> watchHomes();
  List<LocationArea> watchLocations();
  LocationArea? locationById(String id);
  void upsertHome(HomeProfile home);
  void deleteHome(String id);
  void upsertLocation(LocationArea location);
  void deleteLocation(String id);
}

abstract interface class AssetRepository {
  List<HomeAsset> watchAssets();
  List<HomeAsset> archivedAssets();
  HomeAsset? assetById(String id);
  void addAsset(HomeAsset asset);
  void updateAsset(HomeAsset asset);
  HomeAsset? softDeleteAsset(String id);
  void restoreAsset(HomeAsset asset);
}

abstract interface class MaintenanceRepository {
  List<MaintenanceRecord> watchMaintenance();
  List<MaintenanceRecord> forAsset(String assetId);
  void addMaintenance(MaintenanceRecord record);
}

abstract interface class ReminderRepository {
  List<Reminder> watchReminders();
  void addReminder(Reminder reminder);
}

abstract interface class ProviderRepository {
  List<ProviderContact> watchProviders();
  void upsertProvider(ProviderContact provider);
  void deleteProvider(String id);
}

abstract interface class ServiceRepository {
  List<ServicePlan> watchServices();
  void upsertService(ServicePlan service);
  void deleteService(String id);
  void markServiceVisitCompleted(String id);
}

abstract interface class WarrantyRepository {
  List<Warranty> watchWarranties();
  void upsertWarranty(Warranty warranty);
  void deleteWarranty(String id);
}

abstract interface class DocumentRepository {
  List<HomeDocument> watchDocuments();
  void upsertDocument(HomeDocument document);
  void deleteDocument(String id);
}

abstract interface class ExpenseRepository {
  List<Expense> watchExpenses();
  void upsertExpense(Expense expense);
  void deleteExpense(String id);
}

abstract interface class FamilyRepository {
  List<FamilyMember> watchFamily();
  void upsertFamilyMember(FamilyMember member);
  void removeFamilyMember(String id);
}

abstract interface class ActivityRepository {
  List<ActivityEvent> watchActivity();
  void addActivity(ActivityEvent activity);
}
