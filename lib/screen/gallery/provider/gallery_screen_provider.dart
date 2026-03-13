import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/models/category_model.dart';
import '../../../service/api_url.dart';

class GalleryProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  bool isLoading = false;

  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];

  GalleryProvider() {
    fetchCategories();
  }

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

        if (categoryResponse.status) {
          categories = categoryResponse.data;
          filteredCategories = List.from(categories);
        }
      }
    } catch (e) {
      debugPrint("GALLERY CATEGORY API ERROR ❌ $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔍 Search filter
  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategories = List.from(categories);
    } else {
      filteredCategories = categories
          .where((item) =>
          item.categoryName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// 🎤 Mic
  Future<void> toggleListening() async {
    if (!isListening) {
      bool available = await speech.initialize();
      if (available) {
        isListening = true;
        notifyListeners();

        speech.listen(
          onResult: (result) {
            final text = result.recognizedWords;
            searchController.text = text;
            filterCategories(text);
          },
        );
      }
    } else {
      speech.stop();
      isListening = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    speech.stop();
    super.dispose();
  }
}
