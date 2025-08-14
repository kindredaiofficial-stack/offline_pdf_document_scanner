import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_config.dart';
import 'package:offline_pdf_document_scanner/features/iap/iap_service.dart';
import 'package:offline_pdf_document_scanner/features/iap/paywall_page.dart';


class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await Directory.systemTemp.createTemp();
    return dir.path;
  }
}

class _RestoreService extends IapService {
  _RestoreService(super.ref);

  @override
  bool get isAvailable => true;

  @override
  Future<void> restore() async {
    await updateEntitlements(IapConfig.premiumUnlock);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = _FakePathProvider();
  });

  testWidgets('restore flow updates UI', (tester) async {
    final container = ProviderContainer(
      overrides: [iapServiceProvider.overrideWith(_RestoreService.new)],
    );
    addTearDown(container.dispose);

    await container.read(iapEntitlementsProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: PaywallPage()),
      ),
    );
    await tester.pump();

    final buyButtonBefore = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Buy').first,
    );
    expect(buyButtonBefore.onPressed, isNotNull);

    await tester.tap(find.text('Restore purchases'));
    await tester.pump();

    final buyButtonAfter = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Buy').first,
    );
    expect(buyButtonAfter.onPressed, isNull);
  });
}
