import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:offline_pdf_document_scanner/features/ads/ads_widgets.dart';
import 'package:offline_pdf_document_scanner/features/ads/ads_service.dart';
import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';

void main() {
  testWidgets('Premium users see no ads', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adsServiceProvider.overrideWith((ref) => _FakeAdsService(ref)),
          iapEntitlementsProvider.overrideWith(_premiumEntitlements),
        ],
        child: const MaterialApp(home: BannerHost(routeName: '/home')),
      ),
    );
    await tester.pump();
    expect(find.byKey(const Key('test-ad')), findsNothing);
  });
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

IapEntitlementsStore _premiumEntitlements() => _PremiumEntitlements();

class _PremiumEntitlements extends IapEntitlementsStore {
  @override
  Future<Set<IapEntitlement>> build() async => {IapEntitlement.premium};
}
