import 'dart:convert';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/service/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TileListProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  late stt.SpeechToText _speech;
  bool isListening = false;

  List<Product> _allProducts = [];
  List<Product> filteredProducts = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String errorMessage = '';

  int _currentPage = 1;
  static const int _pageSize = 20;

  TileListProvider() {
    _speech = stt.SpeechToText();
  }

  /// Initial load — called once on screen init
  Future<void> fetchProducts(String categoryId) async {
    if (isLoading) return;
    _currentPage = 1;
    _allProducts = [];
    filteredProducts = [];
    hasMore = true;
    errorMessage = '';
    isLoading = true;
    notifyListeners();

    await _fetchPage(categoryId, _currentPage);

    isLoading = false;
    notifyListeners();
  }

  /// Load next page — triggered by scroll controller at bottom
  Future<void> loadMore(String categoryId) async {
    if (isLoadingMore || !hasMore || isLoading) return;
    isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    await _fetchPage(categoryId, _currentPage);

    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _fetchPage(String categoryId, int page) async {
    try {
      final uri = Uri.parse(
          '${ApiUrls.productList}?category_id=$categoryId&page=$page&limit=$_pageSize');
      debugPrint('CATEGORY LIST [page=$page] → $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          final parsed = ProductListResponse.fromJson(data);
          _allProducts.addAll(parsed.data);
          _applySearch(searchController.text);

          // If we got fewer items than the page size, no more pages
          if (parsed.data.length < _pageSize) {
            hasMore = false;
          }
          debugPrint(
              'CATEGORY LIST ✅ Page $page → ${parsed.data.length} items (total: ${_allProducts.length})');
        } else {
          hasMore = false;
          if (_allProducts.isEmpty && data['code'] == 204) {
             errorMessage = "No products found in this category.";
          }
        }
      } else {
        hasMore = false;
        if (_allProducts.isEmpty) errorMessage = "Failed to load products.";
      }
    } catch (e) {
      hasMore = false;
      if (_allProducts.isEmpty) errorMessage = "Error: $e";
      debugPrint('CATEGORY LIST ERROR ❌ $e');
    }
  }

  void _applySearch(String query) {
    if (query.trim().isEmpty) {
      filteredProducts = List.from(_allProducts);
    } else {
      filteredProducts = _allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.tags.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void onSearch(String value) {
    _applySearch(value);
    notifyListeners();
  }

  /// 🎤 START LISTEN
  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      isListening = true;
      notifyListeners();

      _speech.listen(
        onResult: (result) {
          final text = result.recognizedWords;

          searchController.text = text;
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );

          onSearch(text);
        },
      );
    }
  }

  /// 🎤 STOP LISTEN
  void stopListening() {
    _speech.stop();
    isListening = false;
    notifyListeners();
  }
}
