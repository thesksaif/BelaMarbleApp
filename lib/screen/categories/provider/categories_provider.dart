import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/models/category_model.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';

class CategoriesProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();

  late stt.SpeechToText _speech;
  bool isListening = false;
  bool isLoading = false;

  /// Search fired one API call per keystroke; typing "marble" cost 6 requests.
  Timer? _debounce;
  String _lastQuery = '';

  CategoriesProvider() {
    _speech = stt.SpeechToText();
    fetchCategories();
  }

  /// 📦 DATA
  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];

  /// 📥 CATEGORY LIST API
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    isLoading = true;
    notifyListeners();

    try {
      // Shared + cached: Home and Gallery ask for this same endpoint, and they
      // now all resolve from one request.
      final body = await ApiClient.instance.getJson(
        ApiUrls.categoryList,
        forceRefresh: forceRefresh,
      );
      final categoryResponse = CategoryResponse.fromJson(body);

      if (categoryResponse.status) {
        categories = categoryResponse.data;
        filteredCategories = List.from(categories);
      }
    } catch (e) {
      debugPrint("CATEGORY API ERROR ❌ $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔍 SEARCH — debounced so we only call the API once the user pauses.
  void filterCategories(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _lastQuery = '';
      filteredCategories = List.from(categories);
      notifyListeners();
      return;
    }

    // Show local matches immediately so the list reacts while typing, then
    // confirm with the server once typing settles.
    filteredCategories = _localMatches(query);
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      final q = query.trim();
      if (q == _lastQuery) return;
      _lastQuery = q;
      _searchRemote(q);
    });
  }

  List<CategoryModel> _localMatches(String query) {
    final q = query.toLowerCase();
    return categories
        .where((cat) => cat.categoryName.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _searchRemote(String query) async {
    try {
      final data = await ApiClient.instance.postForm(ApiUrls.search, {
        "keyword": query,
      });

      if (data["status"] == true && data["data"] is List) {
        filteredCategories = (data["data"] as List)
            .map<CategoryModel>((item) => CategoryModel.fromJson(item))
            .toList();
      } else {
        filteredCategories = [];
      }
    } catch (e) {
      debugPrint("SEARCH API ERROR ❌ $e");
      filteredCategories = _localMatches(
        query,
      ); // keep local results on failure
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
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}

////////////////////////////////////
