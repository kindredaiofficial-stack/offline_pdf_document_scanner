import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_config.dart';

class IapService {
  IapService(this.ref, [InAppPurchasePlatform? platform])
      : _platform = platform ?? InAppPurchasePlatform.instance;

  final Ref ref;
  final InAppPurchasePlatform _platform;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _available = false;
  Map<String, ProductDetails> _products = {};

  bool get isAvailable => _available;
  Map<String, ProductDetails> get products => _products;

  Future<void> init() async {
    _available = await _platform.isAvailable();
    if (!_available) return;
    await fetchProducts();
    _subscription =
        _platform.purchaseStream.listen(_onPurchaseUpdated, onError: (e) {});
  }

  Future<void> fetchProducts() async {
    final response =
        await _platform.queryProductDetails(IapConfig.allSkus.toSet());
    _products = {for (final p in response.productDetails) p.id: p};
  }

  Future<void> buy(String productId) async {
    if (!_available) return;
    final product = _products[productId];
    if (product == null) return;
    final param = PurchaseParam(productDetails: product);
    await _platform.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (!_available) return;
    await _platform.restorePurchases();
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await updateEntitlements(purchase.productID);
          await _platform.completePurchase(purchase);
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.pending:
        default:
          break;
      }
    }
  }

  @visibleForTesting
  Future<void> updateEntitlements(String productId) async {
    final store = ref.read(iapEntitlementsProvider.notifier);
    switch (productId) {
      case IapConfig.premiumUnlock:
        await store.grant(IapEntitlement.premium);
        break;
      case IapConfig.aiPack:
        await store.grant(IapEntitlement.aiPack);
        break;
      case IapConfig.proToolsPack:
        await store.grant(IapEntitlement.proTools);
        break;
      case IapConfig.ultimate:
        await store.grant(IapEntitlement.premium);
        await store.grant(IapEntitlement.aiPack);
        await store.grant(IapEntitlement.proTools);
        break;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService(ref);
  ref.onDispose(service.dispose);
  return service;
});
