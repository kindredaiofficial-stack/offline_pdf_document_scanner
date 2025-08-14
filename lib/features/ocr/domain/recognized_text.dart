import 'dart:typed_data';
import 'dart:ui';

class OcrInputPage {
  const OcrInputPage({
    required this.index,
    required this.bytes,
    required this.size,
  });

  final int index;
  final Uint8List bytes;
  final Size size;
}

class RecognizedPage {
  const RecognizedPage({
    required this.index,
    required this.boxes,
    required this.pageSize,
  });

  final int index;
  final List<RecognizedBox> boxes;
  final Size pageSize;
}

class RecognizedBox {
  const RecognizedBox({
    required this.rect,
    required this.text,
  });

  final Rect rect;
  final String text;
}
