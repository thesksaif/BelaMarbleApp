/// Builds optimized image URLs.
///
/// The origin (belamarble.com) serves full-resolution JPEGs (~962x1435, ~104 KB)
/// with no `Access-Control-Allow-Origin` and no `Cache-Control` header. So every
/// image goes through the weserv.nl proxy, which:
///   1. adds the CORS header Flutter web needs to draw images onto canvas, and
///   2. resizes + re-encodes to WebP so we download a thumbnail instead of a poster.
///
/// Measured on a real product image:
///   origin direct                 104 KB
///   proxy, no params              110 KB   <- what the app used to request
///   proxy, w=400 &output=webp      23 KB   <- 79% smaller
///
/// Always pass the RAW origin URL here. Models store raw URLs; sizing is a
/// render-time decision because the same image appears as a 100px grid tile and
/// as a full-screen preview.
class AppImageUrl {
  AppImageUrl._();

  /// Widths we actually request. Snapping to a small set means the proxy CDN
  /// caches a handful of variants instead of one per device pixel-ratio.
  static const List<int> _buckets = [200, 400, 800, 1200];

  static int _bucketFor(int width) {
    for (final b in _buckets) {
      if (width <= b) return b;
    }
    return _buckets.last;
  }

  /// Sized, WebP-encoded URL for [rawUrl] rendered at [width] logical pixels.
  ///
  /// Returns an empty string for empty input so callers can keep using
  /// `url.isNotEmpty` checks.
  static String sized(String rawUrl, {required int width, int quality = 80}) {
    if (rawUrl.isEmpty) return '';

    final bucket = _bucketFor(width);
    final clean = _strip(rawUrl);

    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(clean)}'
        '&w=$bucket'
        '&fit=cover'
        '&output=webp'
        '&q=$quality'
        '&we'; // skip enlargement — never upscale a small source
  }

  /// Full-size variant for zoom / detail views. Capped at 1200px because the
  /// source is only ~962px wide; anything larger just wastes bytes.
  static String full(String rawUrl, {int quality = 85}) {
    if (rawUrl.isEmpty) return '';
    return 'https://images.weserv.nl/?url=${Uri.encodeComponent(_strip(rawUrl))}'
        '&w=1200&output=webp&q=$quality&we';
  }

  /// weserv takes the target URL without its scheme.
  static String _strip(String url) {
    var u = url.trim();
    if (u.startsWith('https://')) return u.substring(8);
    if (u.startsWith('http://')) return u.substring(7);
    return u;
  }
}
