import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Shared HTTP entry point for the app.
///
/// Replaces the per-call `http.get(...)` scattered across providers, which had
/// two costs:
///
///   * **A new connection per request.** One [http.Client] keeps the TCP/TLS
///     connection alive, so the 2nd..Nth call to belamarble.com skips the
///     handshake entirely.
///   * **Duplicate work.** `category_list.php` was fetched independently by
///     HomeProvider, CategoriesProvider and GalleryProvider — three identical
///     round trips for one small, rarely-changing payload.
///
/// [getJson] adds a short-lived response cache and in-flight request
/// coalescing, so those three callers now share a single request.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _client = http.Client();

  final Map<String, _CacheEntry> _cache = {};
  final Map<String, Future<dynamic>> _inFlight = {};

  /// How long a cached GET stays fresh. Catalog data changes rarely; pull to
  /// refresh (which passes `forceRefresh: true`) always bypasses this.
  static const Duration defaultTtl = Duration(minutes: 5);

  /// GET [url] and decode the JSON body.
  ///
  /// - Returns the cached value when a previous response is still fresh.
  /// - If an identical request is already running, awaits that one instead of
  ///   starting a second.
  Future<dynamic> getJson(
    String url, {
    Duration ttl = defaultTtl,
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final hit = _cache[url];
      if (hit != null && !hit.isStale(ttl)) {
        return Future.value(hit.body);
      }
      final running = _inFlight[url];
      if (running != null) return running;
    }

    final future = _fetch(url).whenComplete(() => _inFlight.remove(url));
    _inFlight[url] = future;
    return future;
  }

  Future<dynamic> _fetch(String url) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw http.ClientException(
        'GET $url failed with ${response.statusCode}',
        Uri.parse(url),
      );
    }

    final body = jsonDecode(response.body);
    _cache[url] = _CacheEntry(body, DateTime.now());
    return body;
  }

  /// POST a form-encoded body. Not cached — used for search.
  Future<dynamic> postForm(String url, Map<String, String> body) async {
    final response = await _client.post(Uri.parse(url), body: body);
    if (response.statusCode != 200) {
      throw http.ClientException(
        'POST $url failed with ${response.statusCode}',
        Uri.parse(url),
      );
    }
    return jsonDecode(response.body);
  }

  /// Drop cached responses so the next read hits the network.
  void invalidate([String? url]) {
    if (url == null) {
      _cache.clear();
    } else {
      _cache.remove(url);
    }
  }

  @visibleForTesting
  void close() => _client.close();
}

class _CacheEntry {
  final dynamic body;
  final DateTime at;

  _CacheEntry(this.body, this.at);

  bool isStale(Duration ttl) => DateTime.now().difference(at) > ttl;
}
