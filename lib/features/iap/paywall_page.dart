import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entitlements.dart';
import 'iap_config.dart';
import 'iap_service.dart';

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(iapServiceProvider);
    final owned = ref.watch(iapEntitlementsProvider).maybeWhen(
          data: (s) => s,
          orElse: () => <IapEntitlement>{},
        );

    Widget buildCard({
      required String title,
      required String price,
      required String productId,
      String? benefits,
      IapEntitlement? entitlement,
      bool all = false,
    }) {
      final isOwned = all
          ? owned.containsAll(IapEntitlement.values)
          : entitlement != null && owned.contains(entitlement);
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$title — $price',
                  style: Theme.of(context).textTheme.titleMedium),
              if (benefits != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(benefits),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: !service.isAvailable || isOwned
                      ? null
                      : () => service.buy(productId),
                  child: const Text('Buy'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade & Packs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!service.isAvailable)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text('Store unavailable. Check connection.'),
            ),
          buildCard(
            title: 'Premium',
            price: '₹99',
            productId: IapConfig.premiumUnlock,
            benefits: 'Unlock premium features',
            entitlement: IapEntitlement.premium,
          ),
          buildCard(
            title: 'AI Pack',
            price: '₹199',
            productId: IapConfig.aiPack,
            benefits: 'AI OCR pack',
            entitlement: IapEntitlement.aiPack,
          ),
          buildCard(
            title: 'Pro Tools',
            price: '₹149',
            productId: IapConfig.proToolsPack,
            benefits: 'Extra export options',
            entitlement: IapEntitlement.proTools,
          ),
          buildCard(
            title: 'Ultimate',
            price: '₹349',
            productId: IapConfig.ultimate,
            benefits: 'All packs bundled',
            all: true,
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed:
                  service.isAvailable ? () => service.restore() : null,
              child: const Text('Restore purchases'),
            ),
          )
        ],
      ),
    );
  }
}
