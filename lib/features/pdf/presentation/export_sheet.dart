import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../ocr/data/ocr_service.dart';
import '../../ocr/domain/recognized_text.dart';
import '../data/pdf_builder.dart';
import '../../iap/purchase_guard.dart';

class ExportSheet extends ConsumerStatefulWidget {
  const ExportSheet({super.key, required this.pagesBytes});

  final List<Uint8List> pagesBytes;

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  PdfQuality _quality = PdfQuality.mq;
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _subject = TextEditingController();
  final _keywords = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ent = ref.watch(entitlementsProvider);
    final count = widget.pagesBytes.length;
    final allowed = canOcrPages(count, ent);
    final premium = isPremium(ent);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!premium)
                const Text('Free OCR limit: up to 5 pages per document.'),
              _buildQualitySelector(premium),
              _buildMetadataFields(premium),
              if (!premium && count > 5)
                ElevatedButton(
                  onPressed: () => context.push('/paywall'),
                  child: const Text('Upgrade to unlock'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: !allowed || _busy ? null : _export,
                child: _busy
                    ? const CircularProgressIndicator()
                    : const Text('Export PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualitySelector(bool premium) {
    if (!premium) {
      return const ListTile(
        leading: Icon(Icons.lock),
        title: Text('Standard (MQ)'),
      );
    }
    return Column(
      children: PdfQuality.values.map((q) {
        final label = q == PdfQuality.hq
            ? 'High'
            : q == PdfQuality.mq
                ? 'Standard'
                : 'Low';
        return RadioListTile<PdfQuality>(
          title: Text(label),
          value: q,
          groupValue: _quality,
          onChanged: (v) => setState(() => _quality = v ?? PdfQuality.mq),
        );
      }).toList(),
    );
  }

  Widget _buildMetadataFields(bool premium) {
    final enabled = premium;
    InputDecoration deco(String label) => InputDecoration(
          labelText: label,
          suffixIcon: enabled ? null : const Icon(Icons.lock),
        );
    return Column(
      children: [
        TextField(
          controller: _title,
          enabled: enabled,
          decoration: deco('Title'),
        ),
        TextField(
          controller: _author,
          enabled: enabled,
          decoration: deco('Author'),
        ),
        TextField(
          controller: _subject,
          enabled: enabled,
          decoration: deco('Subject'),
        ),
        TextField(
          controller: _keywords,
          enabled: enabled,
          decoration: deco('Keywords'),
        ),
      ],
    );
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final pages = <OcrInputPage>[];
      for (var i = 0; i < widget.pagesBytes.length; i++) {
        final imgData = widget.pagesBytes[i];
        final decoded = img.decodeImage(imgData);
        final size = decoded == null
            ? const Size(0, 0)
            : Size(decoded.width.toDouble(), decoded.height.toDouble());
        pages.add(OcrInputPage(index: i, bytes: imgData, size: size));
      }
      final recognized =
          await ref.read(ocrServiceProvider).recognizeLatin(pages);
      final pdfBytes = await ref.read(pdfBuilderProvider).buildSearchablePdf(
            pageImages: widget.pagesBytes,
            ocr: recognized,
            quality: _quality,
            meta: PdfMetadata(
              title: _title.text.isEmpty ? null : _title.text,
              author: _author.text.isEmpty ? null : _author.text,
              subject: _subject.text.isEmpty ? null : _subject.text,
              keywords: _keywords.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            ),
          );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/export.pdf');
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles([XFile(file.path)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
