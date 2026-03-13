import 'dart:convert';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/service/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class GalleryImagesProvider extends ChangeNotifier {
  String? selectedImage;

  final TextEditingController searchController = TextEditingController();

  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  
  /// PRODUCT DATA
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = false;

  GalleryImagesProvider() {
    _init();
  }
  
  Future<void> _init() async {
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.productList}?page=1&limit=20'),
      );
      
      if (response.statusCode == 200) {
        final productResponse = ProductListResponse.fromJson(jsonDecode(response.body));
        if (productResponse.status) {
          products = productResponse.data;
          filteredProducts = List.from(products);
        }
      }
    } catch (e) {
      debugPrint("GALLERY API ERROR: $e");
    }
    
    isLoading = false;
    notifyListeners();
  }

  /// 🔍 Filter
  void filterProducts(String query) {
    if (query.isEmpty) {
      filteredProducts = List.from(products);
    } else {
      filteredProducts = products.where((item) {
        return item.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  /// 🖼 Image preview
  void selectImage(String image) {
    selectedImage = image;
    notifyListeners();
  }

  void clearSelectedImage() {
    selectedImage = null;
    notifyListeners();
  }

  /// 🎤 Mic
  Future<void> toggleListening() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            isListening = false;
            notifyListeners();
          }
        },
        onError: (_) {
          isListening = false;
          notifyListeners();
        },
      );

      if (available) {
        isListening = true;
        notifyListeners();

        speech.listen(
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
          onResult: (result) {
            final text = result.recognizedWords;
            searchController.text = text;
            filterProducts(text);
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
