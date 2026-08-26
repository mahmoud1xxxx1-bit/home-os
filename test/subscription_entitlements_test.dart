import 'package:flutter_test/flutter_test.dart';
import 'package:home_os/core/subscriptions/entitlements.dart';

void main() {
  group('Home OS subscription entitlements', () {
    test('free tier has the agreed usage limits', () {
      const entitlement = SubscriptionEntitlement(tier: SubscriptionTier.free);
      final limits = entitlement.limits;

      expect(limits.maxHomes, 1);
      expect(limits.maxAssets, 10);
      expect(limits.maxActiveReminders, 10);
      expect(limits.maxMaintenance, 10);
      expect(limits.maxWarranties, 5);
      expect(limits.maxDocuments, 10);
      expect(limits.maxProviders, 3);

      expect(limits.allowsAssets(9), isTrue);
      expect(limits.allowsAssets(10), isFalse);
      expect(limits.allowsWarranties(4), isTrue);
      expect(limits.allowsWarranties(5), isFalse);
    });

    test('unlimited tier unlocks usage but remains one-home', () {
      const entitlement = SubscriptionEntitlement(tier: SubscriptionTier.unlimited);
      final limits = entitlement.limits;

      expect(limits.allowsHomes(0), isTrue);
      expect(limits.allowsHomes(1), isFalse);
      expect(limits.allowsAssets(100000), isTrue);
      expect(limits.allowsReminders(100000), isTrue);
      expect(limits.allowsMaintenance(100000), isTrue);
      expect(limits.allowsWarranties(100000), isTrue);
      expect(limits.allowsDocuments(100000), isTrue);
      expect(limits.allowsProviders(100000), isTrue);
    });

    test('multi-home tier unlocks multiple homes and all usage', () {
      const entitlement = SubscriptionEntitlement(tier: SubscriptionTier.multiHome);
      final limits = entitlement.limits;

      expect(limits.allowsHomes(1000), isTrue);
      expect(limits.allowsAssets(100000), isTrue);
      expect(limits.allowsReminders(100000), isTrue);
    });
  });
}
