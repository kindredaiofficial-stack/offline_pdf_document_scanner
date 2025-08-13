import 'package:go_router/go_router.dart';
import 'package:offline_pdf_document_scanner/features/capture/presentation/capture_page.dart';
import 'package:offline_pdf_document_scanner/features/home/presentation/home_page.dart';
import 'package:offline_pdf_document_scanner/features/pdf/presentation/preview_page.dart';

GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(path: '/capture', builder: (c, s) => const CapturePage()),
    GoRoute(path: '/preview', builder: (c, s) => const PreviewPage()),
  ],
  initialLocation: '/',
);
