import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_config.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await Directory.systemTemp.createTemp();
    return dir.path;
  }
}

class _FakeIapPlatform extends InAppPurchasePlatform {
  final controller = StreamController<List<PurchaseDetails>>.broadcast();
  final List<String> owned = [];

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> ids) async {
    final products = ids
        .map(
          (id) => ProductDetails(
            id: id,
            title: id,
            description: '',
            price: '0',
            rawPrice: 0,
            currencyCode: 'INR',
          ),
        )
        .toList();
    return ProductDetailsResponse(
      productDetails: products,
      notFoundIDs: const [],
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    owned.add(purchaseParam.productDetails.id);
    controller.add([
      PurchaseDetails(
        purchaseID: 't',
        productID: purchaseParam.productDetails.id,
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: '',
          source: '',
        ),
        transactionDate: null,
        status: PurchaseStatus.purchased,
      ),
    ]);
    return true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    controller.add(
      owned
          .map(
            (id) => PurchaseDetails(
              purchaseID: 'r',
              productID: id,
              verificationData: PurchaseVerificationData(
                localVerificationData: '',
                serverVerificationData: '',
                source: '',
              ),
              transactionDate: null,
              status: PurchaseStatus.restored,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  test('grants entitlements for each SKU', () async {
    final platform = _FakeIapPlatform();
    final container = ProviderContainer(
      overrides: [
        iapServiceProvider.overrideWith((ref) => IapService(ref, platform)),
      ],
    );
    addTearDown(container.dispose);
    final service = container.read(iapServiceProvider);

    await container.read(iapEntitlementsProvider.future);
    await service.init();

    final mapping = {
      IapConfig.premiumUnlock: IapEntitlement.premium,
      IapConfig.aiPack: IapEntitlement.aiPack,
      IapConfig.proToolsPack: IapEntitlement.proTools,
    };

    for (final entry in mapping.entries) {
      await service.buy(entry.key);
      await Future.delayed(Duration.zero);
      expect(
        container.read(iapEntitlementsProvider).value,
        contains(entry.value),
      );
    }
  });

  test('ultimate unlocks all', () async {
    final platform = _FakeIapPlatform();
    final container = ProviderContainer(
      overrides: [
        iapServiceProvider.overrideWith((ref) => IapService(ref, platform)),
      ],
    );
    addTearDown(container.dispose);
    final service = container.read(iapServiceProvider);

    await container.read(iapEntitlementsProvider.future);
    await service.init();
    await service.buy(IapConfig.ultimate);
    await Future.delayed(Duration.zero);
    final owned = container.read(iapEntitlementsProvider).value!;
    expect(owned.containsAll(IapEntitlement.values), isTrue);
  });

  test('restore re-grants entitlements', () async {
    final platform = _FakeIapPlatform();
    final container = ProviderContainer(
      overrides: [
        iapServiceProvider.overrideWith((ref) => IapService(ref, platform)),
      ],
    );
    addTearDown(container.dispose);
    final service = container.read(iapServiceProvider);

    await container.read(iapEntitlementsProvider.future);
    await service.init();
    await service.buy(IapConfig.premiumUnlock);
    await Future.delayed(Duration.zero);

    final store = container.read(iapEntitlementsProvider.notifier);
    await store.revoke(IapEntitlement.premium);

    await service.restore();
    await Future.delayed(Duration.zero);
    expect(
      container.read(iapEntitlementsProvider).value,
      contains(IapEntitlement.premium),
    );
  });
}
