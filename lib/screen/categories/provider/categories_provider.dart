import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/models/category_model.dart';
import '../../../service/api_url.dart';

class CategoriesProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  late stt.SpeechToText _speech;
  bool isListening = false;
  bool isLoading = false;

  CategoriesProvider() {
    _speech = stt.SpeechToText();
    fetchCategories();
  }

  /// 📦 DATA
  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];

  /// 📥 CATEGORY LIST API
  Future<void> fetchCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiUrls.categoryList),
      );

      if (response.statusCode == 200) {
        final categoryResponse = CategoryResponse.fromJson(
          jsonDecode(response.body),
        );

        debugPrint("CATEGORY LIST 👉 ${categoryResponse.message}");

        if (categoryResponse.status) {
          categories = categoryResponse.data;
          filteredCategories = List.from(categories);
        }
      } else {
        debugPrint("CATEGORY API ERROR ❌ Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("CATEGORY API ERROR ❌ $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔍 SEARCH
  Future<void> filterCategories(String query) async {
    if (query.isEmpty) {
      filteredCategories = List.from(categories);
      notifyListeners();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiUrls.search),
        body: {"keyword": query},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] is List) {
          filteredCategories = (data["data"] as List)
              .map<CategoryModel>((item) => CategoryModel.fromJson(item))
              .toList();
        } else {
          filteredCategories = [];
        }
      }
    } catch (e) {
      debugPrint("SEARCH API ERROR ❌ $e");
      // Fallback to local search if API fails
      filteredCategories = categories
          .where((cat) =>
              cat.categoryName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  /// 🎤 VOICE SEARCH
  Future<void> listen() async {
    if (!isListening) {
      bool available = await _speech.initialize();
      if (available) {
        isListening = true;
        notifyListeners();

        _speech.listen(
          onResult: (result) {
            final text = result.recognizedWords;
            searchController.text = text;
            filterCategories(text);
          },
        );
      }
    } else {
      isListening = false;
      _speech.stop();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
////////////////////////////////////