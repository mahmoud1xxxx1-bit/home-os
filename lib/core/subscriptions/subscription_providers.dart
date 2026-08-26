import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/extended_repository_providers.dart';
import '../services/local_repositories.dart';
import 'entitlements.dart';

enum LimitedResource { home, asset, reminder, maintenance, warranty, document, provider }

class AccessDecision {
  const AccessDecision.allowed() : allowed = true, requiredTier = null, reasonKey = null;
  const AccessDecision.blocked(this.requiredTier, this.reasonKey) : allowed = false;

  final bool allowed;
  final SubscriptionTier? requiredTier;
  final String? reasonKey;
}

/// Temporary entitlement source until Google Play / App Store billing is wired.
/// Billing will override only this provider; feature screens must not know about stores.
final subscriptionTierProvider = Provider<SubscriptionTier>((ref) => SubscriptionTier.free);

final subscriptionEntitlementProvider = Provider<SubscriptionEntitlement>(
  (ref) => SubscriptionEntitlement(tier: ref.watch(subscriptionTierProvider)),
);

final usageSnapshotProvider = Provider<UsageSnapshot>((ref) {
  final reminders = ref.watch(remindersProvider);
  return UsageSnapshot(
    homes: ref.watch(homesProvider).length,
    assets: ref.watch(assetsProvider).length,
    activeReminders: reminders.where((item) => !item.isDone).length,
    maintenance: ref.watch(maintenanceProvider).length,
    warranties: ref.watch(warrantiesProvider).length,
    documents: ref.watch(documentsProvider).length,
    providers: ref.watch(providersProvider).length,
  );
});

final accessDecisionProvider = Provider.family<AccessDecision, LimitedResource>((ref, resource) {
  final entitlement = ref.watch(subscriptionEntitlementProvider);
  final limits = entitlement.limits;
  final usage = ref.watch(usageSnapshotProvider);

  final allowed = switch (resource) {
    LimitedResource.home => limits.allowsHomes(usage.homes),
    LimitedResource.asset => limits.allowsAssets(usage.assets),
    LimitedResource.reminder => limits.allowsReminders(usage.activeReminders),
    LimitedResource.maintenance => limits.allowsMaintenance(usage.maintenance),
    LimitedResource.warranty => limits.allowsWarranties(usage.warranties),
    LimitedResource.document => limits.allowsDocuments(usage.documents),
    LimitedResource.provider => limits.allowsProviders(usage.providers),
  };

  if (allowed) return const AccessDecision.allowed();

  // A second home is exclusively a Multi-Home entitlement. All other Free limits
  // unlock on Unlimited. Unlimited users that hit the home limit need Multi-Home.
  if (resource == LimitedResource.home) {
    return const AccessDecision.blocked(SubscriptionTier.multiHome, 'multi_home_required');
  }
  return const AccessDecision.blocked(SubscriptionTier.unlimited, 'free_limit_reached');
});
