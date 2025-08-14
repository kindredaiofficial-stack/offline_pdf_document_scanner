import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:offline_pdf_document_scanner/features/iap/iap_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(iapServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
