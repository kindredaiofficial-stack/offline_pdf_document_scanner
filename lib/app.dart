import 'package:flutter/material.dart';
import 'package:offline_pdf_document_scanner/core/theme.dart';
import 'package:offline_pdf_document_scanner/router.dart';

class OfflineScannerApp extends StatelessWidget {
  const OfflineScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'Offline PDF Scanner',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
