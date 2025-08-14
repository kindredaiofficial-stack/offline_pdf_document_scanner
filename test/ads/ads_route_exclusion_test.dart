import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_pdf_document_scanner/features/ads/ads_widgets.dart';
import 'package:offline_pdf_document_scanner/features/ads/ads_service.dart';
import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';

void main() {
  const excluded = ['/capture', '/crop', '/filter', '/annotate', '/export'];
  for (final route in excluded) {
    testWidgets('No banner on route '+route, (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adsServiceProvider.overrideWith((ref) => _FakeAdsService(ref)),
            iapEntitlementsProvider.overrideWith(_fakeEntitlements),
          ],
          child: MaterialApp(home: BannerHost(routeName: route)),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('test-ad')), findsNothing);
    });
  }
}

class _FakeAdsService extends AdsService {
  _FakeAdsService(super.ref);

  @override
  Future<void> init() async {}

  @override
  Widget buildBanner({required BuildContext context, required bool personalized}) {
    return Container(key: const Key('test-ad'), height: 50);
  }
}

IapEntitlementsStore _fakeEntitlements() => _FakeEntitlements();

class _FakeEntitlements extends IapEntitlementsStore {
  @override
  Future<Set<IapEntitlement>> build() async => <IapEntitlement>{};
}
