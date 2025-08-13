import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_document_scanner/app.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OfflineScannerApp()));
    expect(find.text('Offline PDF Scanner'), findsOneWidget);
  });
}
