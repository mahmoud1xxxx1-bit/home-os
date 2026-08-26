import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'billing_contract.dart';
import 'entitlements.dart';

class StoreSubscriptionState {
  const StoreSubscriptionState({
    required this.tier,
    required this.isLoading,
    required this.storeAvailable,
    this.products = const {},
    this.errorCode,
  });

  const StoreSubscriptionState.initial()
      : tier = SubscriptionTier.free,
        isLoading = true,
        storeAvailable = false,
        products = const {},
        errorCode = null;

  final SubscriptionTier tier;
  final bool isLoading;
  final bool storeAvailable;
  final Map<String, ProductDetails> products;
  final String? errorCode;

  StoreSubscriptionState copyWith({
    SubscriptionTier? tier,
    bool? isLoading,
    bool? storeAvailable,
    Map<String, ProductDetails>? products,
    String? errorCode,
    bool clearError = false,
  }) {
    return StoreSubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      products: products ?? this.products,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }

  ProductDetails? productFor(SubscriptionTier target) {
    final id = switch (target) {
      SubscriptionTier.free => null,
      SubscriptionTier.unlimited => SubscriptionProductIds.unlimitedMonthly,
      SubscriptionTier.multiHome => SubscriptionProductIds.multiHomeMonthly,
    };
    return id == null ? null : products[id];
  }
}

final storeSubscriptionControllerProvider =
    NotifierProvider<StoreSubscriptionController, StoreSubscriptionState>(
  StoreSubscriptionController.new,
);

class StoreSubscriptionController extends Notifier<StoreSubscriptionState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  bool _disposed = false;

  @override
  StoreSubscriptionState build() {
    ref.onDispose(() {
      _disposed = true;
      _purchaseSubscription?.cancel();
    });
    Future<void>.microtask(_initialize);
    return const StoreSubscriptionState.initial();
  }

  Future<void> _initialize() async {
    try {
      final available = await _iap.isAvailable();
      if (_disposed) return;
      if (!available) {
        state = state.copyWith(
          isLoading: false,
          storeAvailable: false,
          errorCode: 'store_unavailable',
        );
        return;
      }

      _purchaseSubscription ??= _iap.purchaseStream.listen(
        _handlePurchases,
        onError: (_) {
          if (_disposed) return;
          state = state.copyWith(isLoading: false, errorCode: 'purchase_stream_error');
        },
      );

      const ids = <String>{
        SubscriptionProductIds.unlimitedMonthly,
        SubscriptionProductIds.multiHomeMonthly,
      };
      final response = await _iap.queryProductDetails(ids);
      if (_disposed) return;

      final products = <String, ProductDetails>{
        for (final product in response.productDetails) product.id: product,
      };

      state = state.copyWith(
        storeAvailable: true,
        products: products,
        isLoading: true,
        errorCode: response.error == null ? null : 'product_query_failed',
        clearError: response.error == null,
      );

      // The store remains the source of truth on every launch. Restored/current
      // purchases are emitted through purchaseStream and mapped to entitlements.
      await _iap.restorePurchases();
      if (_disposed) return;
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        storeAvailable: false,
        errorCode: 'store_initialization_failed',
      );
    }
  }

  Future<void> purchase(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) return;
    final product = state.productFor(tier);
    if (!state.storeAvailable || product == null) {
      state = state.copyWith(errorCode: 'product_unavailable');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, errorCode: 'purchase_failed');
    }
  }

  Future<void> restorePurchases() async {
    if (!state.storeAvailable) {
      state = state.copyWith(errorCode: 'store_unavailable');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _iap.restorePurchases();
      if (_disposed) return;
      state = state.copyWith(isLoading: false);
    } catch (_) {
      if (_disposed) return;
      state = state.copyWith(isLoading: false, errorCode: 'restore_failed');
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    var highestTier = SubscriptionTier.free;
    String? errorCode;

    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final tier = _tierForProduct(purchase.productID);
          if (_rank(tier) > _rank(highestTier)) highestTier = tier;
          break;
        case PurchaseStatus.error:
          errorCode = 'purchase_failed';
          break;
        case PurchaseStatus.canceled:
          errorCode = 'purchase_canceled';
          break;
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (_) {
          errorCode ??= 'purchase_completion_failed';
        }
      }
    }

    if (_disposed) return;
    state = state.copyWith(
      tier: highestTier,
      isLoading: purchases.any((purchase) => purchase.status == PurchaseStatus.pending),
      errorCode: errorCode,
      clearError: errorCode == null,
    );
  }

  SubscriptionTier _tierForProduct(String productId) => switch (productId) {
        SubscriptionProductIds.multiHomeMonthly => SubscriptionTier.multiHome,
        SubscriptionProductIds.unlimitedMonthly => SubscriptionTier.unlimited,
        _ => SubscriptionTier.free,
      };

  int _rank(SubscriptionTier tier) => switch (tier) {
        SubscriptionTier.free => 0,
        SubscriptionTier.unlimited => 1,
        SubscriptionTier.multiHome => 2,
      };
}
