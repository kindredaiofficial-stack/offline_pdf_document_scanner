// lib/features/ads/ads_service.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_config.dart';

/// Provides access to advertising services.
final adsServiceProvider = Provider<AdsService>((ref) => AdsService(ref));

class AdsService {
  AdsService(this.ref);
  final Ref ref;

  bool _initialized = false;
  bool _disabled = false; // set if init fails so we never try again

  Future<void> init() async {
    if (_initialized || _disabled) return;
    try {
      // Always await; on some devices init throws if misconfigured.
      await MobileAds.instance.initialize();
      _initialized = true;

      // Optional but useful in dev: mark current device as a test device.
      if (kDebugMode) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: const <String>['TEST_DEVICE_ID']),
        );
      }
    } catch (e, st) {
      _disabled = true;
      debugPrint('Ads disabled: $e\n$st');
    }
  }

  /// Builds a banner widget or [SizedBox.shrink] if not available/allowed.
  Widget buildBanner({
    required BuildContext context,
    required bool personalized,
  }) {
    if (_disabled || !_initialized) return const SizedBox.shrink();

    final request = AdRequest(nonPersonalizedAds: !personalized);
    final id = Platform.isAndroid
        ? AdsConfig.androidBanner
        : AdsConfig.iosBanner;

    return AdWidgetBanner(adUnitId: id, request: request);
  }
}

class AdWidgetBanner extends StatefulWidget {
  const AdWidgetBanner({
    super.key,
    required this.adUnitId,
    required this.request,
  });

  final String adUnitId;
  final AdRequest request;

  @override
  State<AdWidgetBanner> createState() => _AdWidgetBannerState();
}

class _AdWidgetBannerState extends State<AdWidgetBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _banner = BannerAd(
      adUnitId: widget.adUnitId,
      // stick to a very safe size to reduce load failures on emulators
      size: AdSize.banner,
      request: widget.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
          debugPrint('Banner load failed: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) return const SizedBox(height: 0);
    final size = _banner!.size;
    return SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }
}
