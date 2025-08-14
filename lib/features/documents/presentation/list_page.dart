import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_pdf_document_scanner/features/ads/ads_widgets.dart';

class DocumentsListPage extends ConsumerWidget {
  const DocumentsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: const Center(child: Text('Your documents will appear here.')),
      bottomNavigationBar: const BannerHost(routeName: '/documents'),
    );
  }
}
