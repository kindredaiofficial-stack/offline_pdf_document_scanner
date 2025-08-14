import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_pdf_document_scanner/features/pdf/data/pdf_builder.dart';
import 'package:offline_pdf_document_scanner/features/iap/purchase_guard.dart';
import 'package:offline_pdf_document_scanner/features/pdf/presentation/export_sheet.dart';

void main() {
  testWidgets('free tier gated', (tester) async {
    final bytes = Uint8List(0);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementsProvider.overrideWithValue(const Entitlements(premium: false)),
        ],
        child: MaterialApp(
          home: ExportSheet(pagesBytes: List.filled(6, bytes)),
        ),
      ),
    );
    expect(find.text('Upgrade to unlock'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Export PDF'));
    expect(button.onPressed, isNull);
    expect(find.byIcon(Icons.lock), findsWidgets);
    expect(tester.widget<TextField>(find.byType(TextField).first).enabled, isFalse);
  });

  testWidgets('premium tier unlocked', (tester) async {
    final bytes = Uint8List(0);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementsProvider.overrideWithValue(const Entitlements(premium: true)),
        ],
        child: MaterialApp(
          home: ExportSheet(pagesBytes: List.filled(6, bytes)),
        ),
      ),
    );
    expect(find.text('Upgrade to unlock'), findsNothing);
    final button = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Export PDF'));
    expect(button.onPressed, isNotNull);
    expect(tester.widget<TextField>(find.byType(TextField).first).enabled, isTrue);
    expect(find.byType(RadioListTile<PdfQuality>), findsWidgets);
  });
}
