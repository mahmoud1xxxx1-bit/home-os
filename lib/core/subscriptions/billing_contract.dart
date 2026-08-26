import 'entitlements.dart';

class SubscriptionProductIds {
  static const unlimitedMonthly = 'home_os_unlimited_monthly';
  static const multiHomeMonthly = 'home_os_multi_home_monthly';
}

abstract interface class SubscriptionBillingRepository {
  /// Returns only entitlements that have been verified by the billing layer.
  Future<SubscriptionTier> loadVerifiedTier();

  Future<void> purchase(SubscriptionTier tier);

  Future<SubscriptionTier> restorePurchases();
}

/// Billing errors exposed to UI must be mapped to friendly copy instead of
/// leaking Google Play / StoreKit exception text.
class SubscriptionBillingException implements Exception {
  const SubscriptionBillingException(this.code);
  final String code;
}
