/// Ad unit IDs for banners.
class AdsConfig {
  // TODO(owner): replace with real unit IDs; keep test IDs for development
  static const androidBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const iosBanner = 'ca-app-pub-3940256099942544/2934735716';
}

/// Areas where ads may appear.
enum AdsArea { home, documents }

/// Helper to declare where ads are allowed based on route name.
bool adsAllowedForRoute(String routeName) =>
    routeName == '/home' || routeName == '/documents';
