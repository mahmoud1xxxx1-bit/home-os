enum SubscriptionTier { free, unlimited, multiHome }

class UsageSnapshot {
  const UsageSnapshot({
    required this.homes,
    required this.assets,
    required this.activeReminders,
    required this.maintenance,
    required this.warranties,
    required this.documents,
    required this.providers,
  });

  final int homes;
  final int assets;
  final int activeReminders;
  final int maintenance;
  final int warranties;
  final int documents;
  final int providers;
}

class SubscriptionLimits {
  const SubscriptionLimits({
    required this.maxHomes,
    required this.maxAssets,
    required this.maxActiveReminders,
    required this.maxMaintenance,
    required this.maxWarranties,
    required this.maxDocuments,
    required this.maxProviders,
  });

  static const unlimitedValue = -1;

  final int maxHomes;
  final int maxAssets;
  final int maxActiveReminders;
  final int maxMaintenance;
  final int maxWarranties;
  final int maxDocuments;
  final int maxProviders;

  bool _allows(int used, int max) => max == unlimitedValue || used < max;

  bool allowsHomes(int used) => _allows(used, maxHomes);
  bool allowsAssets(int used) => _allows(used, maxAssets);
  bool allowsReminders(int used) => _allows(used, maxActiveReminders);
  bool allowsMaintenance(int used) => _allows(used, maxMaintenance);
  bool allowsWarranties(int used) => _allows(used, maxWarranties);
  bool allowsDocuments(int used) => _allows(used, maxDocuments);
  bool allowsProviders(int used) => _allows(used, maxProviders);
}

class SubscriptionEntitlement {
  const SubscriptionEntitlement({required this.tier});

  final SubscriptionTier tier;

  static const freeLimits = SubscriptionLimits(
    maxHomes: 1,
    maxAssets: 10,
    maxActiveReminders: 10,
    maxMaintenance: 10,
    maxWarranties: 5,
    maxDocuments: 10,
    maxProviders: 3,
  );

  static const unlimitedLimits = SubscriptionLimits(
    maxHomes: 1,
    maxAssets: SubscriptionLimits.unlimitedValue,
    maxActiveReminders: SubscriptionLimits.unlimitedValue,
    maxMaintenance: SubscriptionLimits.unlimitedValue,
    maxWarranties: SubscriptionLimits.unlimitedValue,
    maxDocuments: SubscriptionLimits.unlimitedValue,
    maxProviders: SubscriptionLimits.unlimitedValue,
  );

  static const multiHomeLimits = SubscriptionLimits(
    maxHomes: SubscriptionLimits.unlimitedValue,
    maxAssets: SubscriptionLimits.unlimitedValue,
    maxActiveReminders: SubscriptionLimits.unlimitedValue,
    maxMaintenance: SubscriptionLimits.unlimitedValue,
    maxWarranties: SubscriptionLimits.unlimitedValue,
    maxDocuments: SubscriptionLimits.unlimitedValue,
    maxProviders: SubscriptionLimits.unlimitedValue,
  );

  SubscriptionLimits get limits => switch (tier) {
        SubscriptionTier.free => freeLimits,
        SubscriptionTier.unlimited => unlimitedLimits,
        SubscriptionTier.multiHome => multiHomeLimits,
      };

  String priceLabel(String lang) => switch (tier) {
        SubscriptionTier.free => lang == 'ar' ? 'مجانية' : 'Free',
        SubscriptionTier.unlimited => r'$20 / month',
        SubscriptionTier.multiHome => r'$35 / month',
      };

  String title(String lang) => switch (tier) {
        SubscriptionTier.free => lang == 'ar' ? 'Home OS Free' : 'Home OS Free',
        SubscriptionTier.unlimited => lang == 'ar' ? 'Home OS Unlimited' : 'Home OS Unlimited',
        SubscriptionTier.multiHome => lang == 'ar' ? 'Home OS Multi‑Home' : 'Home OS Multi‑Home',
      };
}
