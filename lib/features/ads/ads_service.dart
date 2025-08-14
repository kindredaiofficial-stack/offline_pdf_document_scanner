import 'dart:io';

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

  Future<void> init() async {
    if (_initialized) return;
    MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Builds a banner widget or [SizedBox.shrink] if not allowed/available.
  /// [personalized] toggles nonPersonalizedAds in [AdRequest].
  Widget buildBanner({required BuildContext context, required bool personalized}) {
    if (!_initialized) return const SizedBox.shrink();
    final adSize = AdSize.banner;
    final request = AdRequest(
      nonPersonalizedAds: !personalized,
    );
    return AdWidgetBanner(
      adUnitId: Platform.isAndroid ? AdsConfig.androidBanner : AdsConfig.iosBanner,
      size: adSize,
      request: request,
    );
  }
}

class AdWidgetBanner extends StatefulWidget {
  const AdWidgetBanner({
    super.key,
    required this.adUnitId,
    required this.size,
    required this.request,
  });

  final String adUnitId;
  final AdSize size;
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
      size: widget.size,
      request: widget.request,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _banner = null;
            _loaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _banner == null) {
      return const SizedBox(height: 0);
    }
    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }
}
