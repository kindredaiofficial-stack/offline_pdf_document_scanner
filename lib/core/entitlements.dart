import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

/// Features that may require an entitlement to access.
enum Feature { capture, ocr, exportPdf }

class EntitlementsStore extends AsyncNotifier<Set<Feature>> {
  static const _fileName = 'entitlements.json';

  @override
  Future<Set<Feature>> build() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString()) as List<dynamic>;
      return data.map((e) => Feature.values.byName(e as String)).toSet();
    }
    return <Feature>{};
  }

  Future<void> _save(Set<Feature> entitlements) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');
    await file.writeAsString(
      jsonEncode(entitlements.map((e) => e.name).toList()),
    );
  }

  Future<void> grant(Feature feature) async {
    final newState = {...(state.value ?? {}), feature};
    state = AsyncData(newState);
    await _save(newState);
  }

  Future<void> revoke(Feature feature) async {
    final newState = {...(state.value ?? {})}..remove(feature);
    state = AsyncData(newState);
    await _save(newState);
  }

  bool isEntitled(Feature feature) => state.value?.contains(feature) ?? false;
}

final entitlementsProvider =
    AsyncNotifierProvider<EntitlementsStore, Set<Feature>>(EntitlementsStore.new);

final featureUnlockedProvider = Provider.family<bool, Feature>((ref, feature) {
  final entitlements = ref.watch(entitlementsProvider).maybeWhen(
        data: (value) => value,
        orElse: () => <Feature>{},
      );
  return entitlements.contains(feature);
});
