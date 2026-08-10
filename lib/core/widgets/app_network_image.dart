import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/image_url.dart';

/// Network image with three things plain [Image.network] does not do:
///
///   1. **Resizing at the source** — requests a WebP thumbnail sized to the slot
///      instead of the full ~962x1435 original.
///   2. **Disk caching** — survives scrolling away and app restarts, so a
///      revisited screen costs zero network.
///   3. **Decode capping** — `memCacheWidth` stops Flutter decoding a 962x1435
///      bitmap (~5.5 MB of RAM) into a 100px tile.
///
/// Pass the RAW origin URL; sizing is handled here.
class AppNetworkImage extends StatelessWidget {
  /// Raw origin URL, straight from the API.
  final String url;

  /// Slot width in logical pixels. Drives both the requested size and the
  /// decode cap. Pass the real rendered width, not the image's natural size.
  final double width;

  final BoxFit fit;

  /// Request the full-size variant instead of a thumbnail (zoom / detail views).
  final bool fullSize;

  final BorderRadius? borderRadius;

  const AppNetworkImage({
    super.key,
    required this.url,
    required this.width,
    this.fit = BoxFit.cover,
    this.fullSize = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallback(Icons.image);

    // Account for the screen's pixel ratio so images stay sharp on 2x/3x
    // displays, then let AppImageUrl snap it to a cache-friendly bucket.
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2.0;
    final targetPx = (width * dpr).round().clamp(100, 1200);

    final resolved = fullSize
        ? AppImageUrl.full(url)
        : AppImageUrl.sized(url, width: targetPx);

    Widget image = CachedNetworkImage(
      imageUrl: resolved,
      fit: fit,
      width: double.infinity,
      // Cap the decoded bitmap. Without this a grid of 20 tiles can hold
      // >100 MB of decoded pixels.
      memCacheWidth: fullSize ? 1200 : targetPx,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => Container(color: Colors.grey[200]),
      errorWidget: (_, __, ___) => _fallback(Icons.broken_image),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _fallback(IconData icon) => Container(
    color: Colors.grey[200],
    child: Icon(icon, size: 40, color: Colors.grey),
  );
}

/// [ImageProvider] flavour for the places that paint through
/// `BoxDecoration(image: DecorationImage(...))`.
///
/// Same resizing and disk caching as [AppNetworkImage]; use that widget when you
/// can, and this only where a decoration is genuinely required.
ImageProvider appImageProvider(
  String url, {
  required double width,
  double devicePixelRatio = 2.0,
}) {
  final targetPx = (width * devicePixelRatio).round().clamp(100, 1200);
  return CachedNetworkImageProvider(
    AppImageUrl.sized(url, width: targetPx),
    maxWidth: targetPx,
  );
}
