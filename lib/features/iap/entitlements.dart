import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// In-app purchase entitlements.
enum IapEntitlement { premium, aiPack, proTools }

class IapEntitlementsStore extends AsyncNotifier<Set<IapEntitlement>> {
  static const _fileName = 'iap_entitlements.json';

  @override
  Future<Set<IapEntitlement>> build() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      return data.map((e) => IapEntitlement.values.byName(e as String)).toSet();
    }
    return <IapEntitlement>{};
  }

  Future<void> _save(Set<IapEntitlement> entitlements) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    await file.writeAsString(
      jsonEncode(entitlements.map((e) => e.name).toList()),
    );
  }

  Future<void> grant(IapEntitlement entitlement) async {
    final newState = <IapEntitlement>{...(state.value ?? {}), entitlement};
    state = AsyncData(newState);
    await _save(newState);
  }

  Future<void> revoke(IapEntitlement entitlement) async {
    final newState = <IapEntitlement>{...(state.value ?? {})}
      ..remove(entitlement);
    state = AsyncData(newState);
    await _save(newState);
  }

  bool isOwned(IapEntitlement entitlement) =>
      state.value?.contains(entitlement) ?? false;
}

final iapEntitlementsProvider =
    AsyncNotifierProvider<IapEntitlementsStore, Set<IapEntitlement>>(
      IapEntitlementsStore.new,
    );

final entitlementOwnedProvider = Provider.family<bool, IapEntitlement>((
  ref,
  entitlement,
) {
  final entitlements = ref
      .watch(iapEntitlementsProvider)
      .maybeWhen(data: (value) => value, orElse: () => <IapEntitlement>{});
  return entitlements.contains(entitlement);
});
