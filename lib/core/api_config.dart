import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  // Override at runtime:
  // flutter run --dart-define=API_BASE_URL=http://YOUR_BACKEND_HOST:8000
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return _normalizeApiBaseUrl(fromEnv);
    }

    if (kIsWeb) {
      return _normalizeApiBaseUrl('http://164.68.125.87/api');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _normalizeApiBaseUrl('http://164.68.125.87/api');
      default:
        return _normalizeApiBaseUrl('http://164.68.125.87/api');
    }
  }

  static String get apiBaseUrl => baseUrl;

  static String _normalizeApiBaseUrl(String value) {
    var base = value.trim();
    while (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    return base.endsWith('/api') ? base : '$base/api';
  }

  /// Laravel origin without `/api` — for resolving `avatar_url` if the API returns a relative path.
  static String get origin {
    var o = baseUrl.trim();
    if (o.endsWith('/api')) {
      o = o.substring(0, o.length - 4);
    }
    while (o.endsWith('/')) {
      o = o.substring(0, o.length - 1);
    }
    return o;
  }

  /// Full URL for a path like `/storage/...` or an absolute URL from the API.
  static String? mediaUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
    final s = pathOrUrl.trim();
    if (s.startsWith('http')) {
      return _rewriteLocalHostsToApiOrigin(s);
    }
    if (s.startsWith('/')) return '$origin$s';
    return '$origin/$s';
  }

  /// Rewrite storage URLs so they load from the same host the app uses for the API.
  /// See [luxora] `ApiMediaUrl` for the same rules.
  static String _rewriteLocalHostsToApiOrigin(String url) {
    final parsed = Uri.tryParse(url);
    if (parsed == null) return url;
    final api = Uri.parse(origin);
    final host = parsed.host.toLowerCase();
    final isLoopback = host == 'localhost' || host == '127.0.0.1';
    final isLaravelStorage = parsed.path.startsWith('/storage/');
    final rewriteStorageToApiHost =
        isLaravelStorage && parsed.scheme == 'http';

    if (isLoopback || rewriteStorageToApiHost) {
      // Keep :8000 (or whatever port the JSON had); `port: null` can drop to 80.
      return parsed.replace(
        scheme: api.scheme,
        host: api.host,
        port: parsed.port,
      ).toString();
    }
    return url;
  }
}
