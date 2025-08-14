import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:offline_pdf_document_scanner/features/pdf/data/pdf_builder.dart';

void main() {
  test('mapOcrRectToPdf flips Y axis', () {
    const pageSize = Size(100, 200);
    const rect = Rect.fromLTWH(10, 20, 30, 40);
    final offset = mapOcrRectToPdf(rect, pageSize);
    expect(offset.dx, 10);
    expect(offset.dy, 200 - 20 - 40);
  });
}
