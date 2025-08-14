import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_config.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_service.dart';
import 'package:offline_pdf_document_scanner/features/iap/paywall_page.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';

class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await Directory.systemTemp.createTemp();
    return dir.path;
  }
}

class _FakeIapService extends IapService {
  _FakeIapService(Ref ref) : super(ref);

  int buyCalls = 0;
  int restoreCalls = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<void> buy(String productId) async {
    buyCalls++;
  }

  @override
  Future<void> restore() async {
    restoreCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  testWidgets('buy disabled when owned and buttons trigger service',
      (tester) async {
    final service = _FakeIapService(ProviderContainer().read);
    final container = ProviderContainer(overrides: [
      iapServiceProvider.overrideWithValue(service),
    ]);
    addTearDown(container.dispose);

    await container.read(iapEntitlementsProvider.future);
    await service.updateEntitlements(IapConfig.premiumUnlock);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: PaywallPage()),
    ));
    await tester.pump();

    final buttons = find.widgetWithText(ElevatedButton, 'Buy');
    final premiumButton = tester.widget<ElevatedButton>(buttons.at(0));
    expect(premiumButton.onPressed, isNull);

    await tester.tap(buttons.at(1));
    await tester.pump();
    expect(service.buyCalls, 1);

    await tester.tap(find.text('Restore purchases'));
    await tester.pump();
    expect(service.restoreCalls, 1);
  });
}
