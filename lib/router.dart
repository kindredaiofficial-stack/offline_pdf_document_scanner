import 'package:go_router/go_router.dart';

import 'package:offline_pdf_document_scanner/features/capture/presentation/capture_page.dart';
import 'package:offline_pdf_document_scanner/features/home/presentation/home_page.dart';
import 'package:offline_pdf_document_scanner/features/documents/presentation/list_page.dart';
import 'package:offline_pdf_document_scanner/features/iap/paywall_page.dart';
import 'package:offline_pdf_document_scanner/features/pdf/presentation/preview_page.dart';

GoRouter buildRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/home'),
        GoRoute(path: '/home', builder: (c, s) => const HomePage()),
        GoRoute(path: '/documents', builder: (c, s) => const DocumentsListPage()),
        GoRoute(path: '/capture', builder: (c, s) => const CapturePage()),
        GoRoute(path: '/preview', builder: (c, s) => const PreviewPage()),
        GoRoute(path: '/paywall', builder: (c, s) => const PaywallPage()),
      ],
      initialLocation: '/home',
    );
