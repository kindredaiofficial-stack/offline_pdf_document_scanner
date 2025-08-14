import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:offline_pdf_document_scanner/features/ads/ads_prefs.dart';

void main() {
  test('personalized ads preference persists', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    await Future.delayed(Duration.zero);
    expect(container.read(adsPrefsProvider).personalizedAds, isTrue);

    await container.read(adsPrefsProvider.notifier).setPersonalizedAds(false);
    await Future.delayed(Duration.zero);
    expect(container.read(adsPrefsProvider).personalizedAds, isFalse);

    final container2 = ProviderContainer();
    await Future.delayed(Duration.zero);
    expect(container2.read(adsPrefsProvider).personalizedAds, isFalse);
  });
}
