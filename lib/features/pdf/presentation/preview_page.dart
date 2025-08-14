import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'export_sheet.dart';

final sessionPagesProvider =
    StateProvider<List<Uint8List>>((ref) => <Uint8List>[]);

class PreviewPage extends ConsumerWidget {
  const PreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(sessionPagesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Preview PDF')),
      body: pages.isEmpty
          ? const Center(child: Text('No pages'))
          : ListView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8),
                child: Image.memory(pages[index]),
              ),
            ),
      floatingActionButton: pages.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (c) => ExportSheet(pagesBytes: pages),
                );
              },
              label: const Text('Export'),
            ),
    );
  }
}
