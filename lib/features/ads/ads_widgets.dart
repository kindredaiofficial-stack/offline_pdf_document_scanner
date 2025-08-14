import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_config.dart';
import 'ads_prefs.dart';
import 'ads_service.dart';
import '../iap/entitlements.dart';

class BannerHost extends ConsumerWidget {
  const BannerHost({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!adsAllowedForRoute(routeName)) {
      return const SizedBox.shrink();
    }

    final entitlements = ref
        .watch(iapEntitlementsProvider)
        .maybeWhen(data: (e) => e, orElse: () => <IapEntitlement>{});
    if (entitlements.contains(IapEntitlement.premium)) {
      return const SizedBox.shrink();
    }

    final viewInsets = MediaQuery.of(context).viewInsets;
    if (viewInsets.bottom > 0) {
      return const SizedBox.shrink();
    }

    final height = MediaQuery.of(context).size.height;
    if (height < 480) {
      return const SizedBox.shrink();
    }

    final prefs = ref.watch(adsPrefsProvider);
    final service = ref.watch(adsServiceProvider);
    service.init();

    return service.buildBanner(
      context: context,
      personalized: prefs.personalizedAds,
    );
  }
}
