import 'app_models.dart';

abstract interface class HomeRepository {
  List<HomeProfile> watchHomes();
  List<LocationArea> watchLocations();
  LocationArea? locationById(String id);
}

abstract interface class AssetRepository {
  List<HomeAsset> watchAssets();
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
}

abstract interface class DocumentRepository {
  List<HomeDocument> watchDocuments();
}

abstract interface class ExpenseRepository {
  List<Expense> watchExpenses();
}

abstract interface class ActivityRepository {
  List<ActivityEvent> watchActivity();
  void addActivity(ActivityEvent activity);
}
