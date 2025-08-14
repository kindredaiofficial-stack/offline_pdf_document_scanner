import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_pdf_document_scanner/core/entitlements.dart';
import 'package:offline_pdf_document_scanner/features/ads/ads_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCapture = ref.watch(featureUnlockedProvider(Feature.capture));

    return Scaffold(
      appBar: AppBar(title: const Text('Offline PDF Scanner')),
      body: const Center(child: Text('Recent documents will appear here.')),
      bottomNavigationBar: const BannerHost(routeName: '/home'),
      floatingActionButton: canCapture
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/capture'),
              label: const Text('New Scan'),
              icon: const Icon(Icons.camera_alt_outlined),
            )
          : null,
    );
  }
}
