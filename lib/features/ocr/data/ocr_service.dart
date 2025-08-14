import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../domain/recognized_text.dart';

class OcrService {
  Future<List<RecognizedPage>> recognizeLatin(
      List<OcrInputPage> pages) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final results = <RecognizedPage>[];
      for (final page in pages) {
        try {
          final metadata = InputImageMetadata(
            size: page.size,
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.bgra8888,
            bytesPerRow: page.size.width.toInt() * 4,
          );
          final input = InputImage.fromBytes(
            bytes: page.bytes,
            metadata: metadata,
          );
          final recognized = await recognizer.processImage(input);
          final boxes = <RecognizedBox>[];
          for (final block in recognized.blocks) {
            final rect = block.boundingBox;
            if (rect != null) {
              boxes.add(RecognizedBox(rect: rect, text: block.text));
            }
          }
          results.add(RecognizedPage(
            index: page.index,
            boxes: boxes,
            pageSize: page.size,
          ));
        } catch (_) {
          results.add(RecognizedPage(
            index: page.index,
            boxes: const [],
            pageSize: page.size,
          ));
        }
      }
      return results;
    } finally {
      await recognizer.close();
    }
  }
}

final ocrServiceProvider = Provider<OcrService>((ref) => OcrService());
