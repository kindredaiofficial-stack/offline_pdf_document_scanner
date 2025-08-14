import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_pdf_document_scanner/core/entitlements.dart';
import 'package:offline_pdf_document_scanner/features/ads/ads_widgets.dart';
import 'package:offline_pdf_document_scanner/features/pdf/presentation/preview_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCapture = ref.watch(featureUnlockedProvider(Feature.capture));

    return Scaffold(
      appBar: AppBar(title: const Text('Offline PDF Scanner')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Recent documents will appear here.'),
            const SizedBox(height: 16),
            // TODO(owner): Remove or hide in release.
            ElevatedButton(
              onPressed: () async {
                final bytes = await _demoPage();
                final notifier = ref.read(sessionPagesProvider.notifier);
                notifier.state = [...notifier.state, bytes];
              },
              child: const Text('Import demo page'),
            ),
            // TODO(owner): Remove or hide in release.
            ElevatedButton(
              onPressed: () => context.push('/preview'),
              child: const Text('Open preview'),
            ),
          ],
        ),
      ),
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

Future<Uint8List> _demoPage() async {
  const size = ui.Size(200, 60);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint()..color = Colors.white;
  canvas.drawRect(Offset.zero & size, paint);
  final textPainter = TextPainter(
    text: const TextSpan(
      text: 'Hello OCR',
      style: TextStyle(color: Colors.black, fontSize: 20),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  textPainter.paint(canvas, const Offset(10, 20));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}
