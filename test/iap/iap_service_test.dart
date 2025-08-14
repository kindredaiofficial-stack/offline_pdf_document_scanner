import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_config.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_service.dart';
import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await Directory.systemTemp.createTemp();
    return dir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  test('grants entitlements for each SKU', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final service = IapService(container.read);

    await container.read(iapEntitlementsProvider.future);

    await service.updateEntitlements(IapConfig.premiumUnlock);
    expect(
      container.read(iapEntitlementsProvider).value,
      contains(IapEntitlement.premium),
    );

    await service.updateEntitlements(IapConfig.aiPack);
    expect(
      container.read(iapEntitlementsProvider).value,
      contains(IapEntitlement.aiPack),
    );

    await service.updateEntitlements(IapConfig.proToolsPack);
    expect(
      container.read(iapEntitlementsProvider).value,
      contains(IapEntitlement.proTools),
    );
  });

  test('ultimate unlocks all', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final service = IapService(container.read);

    await container.read(iapEntitlementsProvider.future);
    await service.updateEntitlements(IapConfig.ultimate);
    final owned = container.read(iapEntitlementsProvider).value!;
    expect(owned.containsAll(IapEntitlement.values), isTrue);
  });

  test('restore re-grants entitlements', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final service = IapService(container.read);

    await container.read(iapEntitlementsProvider.future);
    await service.updateEntitlements(IapConfig.premiumUnlock);
    final store = container.read(iapEntitlementsProvider.notifier);
    await store.revoke(IapEntitlement.premium);
    await service.updateEntitlements(IapConfig.premiumUnlock);
    expect(
      container.read(iapEntitlementsProvider).value,
      contains(IapEntitlement.premium),
    );
  });
}
