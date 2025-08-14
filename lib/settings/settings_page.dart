import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:offline_pdf_document_scanner/features/iap/iap_service.dart';
import 'package:offline_pdf_document_scanner/features/ads/ads_prefs.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(iapServiceProvider);
    final adsPrefs = ref.watch(adsPrefsProvider);
    final adsPrefsNotifier = ref.read(adsPrefsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Personalized ads'),
              subtitle: const Text(
                'You can turn off personalized ads. You may still see ads.',
              ),
              value: adsPrefs.personalizedAds,
              onChanged: adsPrefsNotifier.setPersonalizedAds,
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Upgrade & Packs'),
                  onTap: () => context.push('/paywall'),
                ),
                ListTile(
                  title: const Text('Restore purchases'),
                  onTap: service.restore,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
