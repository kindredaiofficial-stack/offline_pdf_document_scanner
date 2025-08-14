import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_document_scanner/core/entitlements.dart';
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

  test('grants and revokes features', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(entitlementsProvider.future);
    final store = container.read(entitlementsProvider.notifier);

    await store.grant(Feature.capture);
    expect(container.read(entitlementsProvider).value, {Feature.capture});

    await store.revoke(Feature.capture);
    expect(container.read(entitlementsProvider).value, <Feature>{});
  });
}
