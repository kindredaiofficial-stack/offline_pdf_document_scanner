import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:offline_pdf_document_scanner/features/ocr/data/ocr_service.dart';
import 'package:offline_pdf_document_scanner/features/ocr/domain/recognized_text.dart';
import 'package:offline_pdf_document_scanner/features/pdf/data/pdf_builder.dart';

class FakeOcrService extends OcrService {
  @override
  Future<List<RecognizedPage>> recognizeLatin(List<OcrInputPage> pages) async {
    return [
      RecognizedPage(
        index: 0,
        boxes: const [
          RecognizedBox(rect: Rect.fromLTWH(10, 10, 100, 20), text: 'Hello'),
        ],
        pageSize: pages.first.size,
      )
    ];
  }
}

void main() {
  test('builds searchable PDF with OCR layer', () async {
    final image = img.Image(width: 200, height: 60);
    image.fill(0xffffffff);
    final pageBytes = Uint8List.fromList(img.encodeJpg(image));
    final ocr = await FakeOcrService().recognizeLatin([
      OcrInputPage(index: 0, bytes: pageBytes, size: const Size(200, 60)),
    ]);
    final pdf = await PdfBuilder().buildSearchablePdf(
      pageImages: [pageBytes],
      ocr: ocr,
      quality: PdfQuality.hq,
      meta: const PdfMetadata(),
    );
    expect(pdf, isNotEmpty);
    expect(String.fromCharCodes(pdf).contains('Hello'), isTrue);
  });
}
