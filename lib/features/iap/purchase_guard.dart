import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:offline_pdf_document_scanner/features/iap/entitlements.dart';

class Entitlements {
  const Entitlements({this.premium = false});
  final bool premium;
}

bool canOcrPages(int count, Entitlements e) => e.premium ? true : count <= 5;
bool isPremium(Entitlements e) => e.premium == true;

final entitlementsProvider = Provider<Entitlements>((ref) {
  final owned = ref.watch(iapEntitlementsProvider).maybeWhen(
        data: (v) => v,
        orElse: () => <IapEntitlement>{},
      );
  return Entitlements(premium: owned.contains(IapEntitlement.premium));
});

class PurchaseGuard extends ConsumerWidget {
  const PurchaseGuard({
    super.key,
    required this.entitlement,
    required this.child,
  });

  final IapEntitlement entitlement;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(entitlementOwnedProvider(entitlement));
    if (owned) return child;
    return Center(
      child: ElevatedButton(
        onPressed: () => context.push('/paywall'),
        child: const Text('Unlock'),
      ),
    );
  }
}
