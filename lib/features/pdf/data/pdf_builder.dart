import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../ocr/domain/recognized_text.dart';

enum PdfQuality { hq, mq, lq }

class PdfMetadata {
  const PdfMetadata({
    this.title,
    this.author,
    this.subject,
    this.keywords = const [],
  });

  final String? title;
  final String? author;
  final String? subject;
  final List<String> keywords;
}

Offset mapOcrRectToPdf(Rect rect, Size pageSize) {
  final dy = pageSize.height - rect.top - rect.height;
  return Offset(rect.left, dy);
}

class PdfBuilder {
  Future<Uint8List> buildSearchablePdf({
    required List<Uint8List> pageImages,
    required List<RecognizedPage> ocr,
    required PdfQuality quality,
    required PdfMetadata meta,
    bool addPageNumbers = false,
  }) async {
    final doc = pw.Document(
      title: meta.title,
      author: meta.author,
      subject: meta.subject,
      keywords: meta.keywords.join(', '),
    );

    final jpegQuality = quality == PdfQuality.hq
        ? 90
        : quality == PdfQuality.mq
            ? 75
            : 60;
    final scale = quality == PdfQuality.hq
        ? 1.0
        : quality == PdfQuality.mq
            ? 0.75
            : 0.6;

    for (var i = 0; i < pageImages.length; i++) {
      final data = pageImages[i];
      var image = img.decodeImage(data)!;
      if (scale != 1.0) {
        image = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
        );
      }
      final jpg = img.encodeJpg(image, quality: jpegQuality);
      final pageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final pageOcr = ocr.firstWhere(
        (p) => p.index == i,
        orElse: () => RecognizedPage(
          index: i,
          boxes: const [],
          pageSize: pageSize,
        ),
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageSize.width, pageSize.height),
          build: (context) {
            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(pw.MemoryImage(Uint8List.fromList(jpg))),
                ),
                for (final box in pageOcr.boxes)
                  pw.Positioned(
                    left: box.rect.left,
                    top: mapOcrRectToPdf(box.rect, pageSize).dy,
                    child: pw.Text(
                      box.text,
                      style: pw.TextStyle(
                        fontSize: box.rect.height,
                        font: pw.Font.helvetica(),
                        renderingMode: PdfTextRenderingMode.invisible,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    return Uint8List.fromList(await doc.save());
  }
}

final pdfBuilderProvider = Provider<PdfBuilder>((ref) => PdfBuilder());
