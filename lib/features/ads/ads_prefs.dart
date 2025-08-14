import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsPrefs {
  AdsPrefs({this.personalizedAds = true});
  final bool personalizedAds;

  AdsPrefs copyWith({bool? personalizedAds}) =>
      AdsPrefs(personalizedAds: personalizedAds ?? this.personalizedAds);
}

class AdsPrefsNotifier extends StateNotifier<AdsPrefs> {
  AdsPrefsNotifier() : super(AdsPrefs()) {
    _load();
  }

  static const _keyPersonalized = 'ads_personalized';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_keyPersonalized) ?? true;
    state = AdsPrefs(personalizedAds: value);
  }

  Future<void> setPersonalizedAds(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPersonalized, value);
    state = AdsPrefs(personalizedAds: value);
  }
}

final adsPrefsProvider =
    StateNotifierProvider<AdsPrefsNotifier, AdsPrefs>(AdsPrefsNotifier.new);
