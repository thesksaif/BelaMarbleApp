import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/search_model.dart';
import '../../../service/api_url.dart';

class SearchProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  SearchResponse? searchResponse;
  String errorMessage = '';

  /// Search API Call
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      searchResponse = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.search}?q=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        searchResponse = SearchResponse.fromJson(data);

        debugPrint(
          "SEARCH API ✅ Found: ${searchResponse!.total.categories} categories, ${searchResponse!.total.products} products",
        );
      } else {
        errorMessage = 'Failed to search';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      debugPrint("SEARCH API ERROR ❌ $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    searchResponse = null;
    errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
