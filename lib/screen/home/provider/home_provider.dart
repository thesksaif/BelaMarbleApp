import 'dart:async';
import 'dart:convert';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/service/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeProvider extends ChangeNotifier {
  /// Banner Controller
  final PageController pageController =
  PageController(viewportFraction: 0.88, initialPage: 0); // initialPage 0 is safer when loading dynamic data

  int _currentPage = 0;
  int get currentPage => _currentPage;

  /// Timer for auto-scrolling banners
  Timer? _timer;

  /// Dynamic Banner Images
  List<String> bannerImages = [];
  bool isSlidersLoading = false;

  /// Categories from API
  List<Map<String, String>> categories = [];
  bool isCategoriesLoading = false;

  /// Recent Products from API
  List<Product> recentProducts = [];
  bool isProductsLoading = false;

  HomeProvider() {
    _initData();
  }

  Future<void> _initData() async {
    await fetchSliders();
    _startAutoScroll(); // Start scrolling only after we have data
    fetchCategories();
    fetchRecentProducts();
  }

  /// Fetch Sliders from API
  Future<void> fetchSliders() async {
    isSlidersLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiUrls.sliderList));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] is List) {
          bannerImages = (data["data"] as List)
              .map<String>((item) => item["image"].toString())
              .toList();
        }
      }
    } catch (e) {
      debugPrint("HOME SLIDER API ERROR ❌ $e");
    }

    isSlidersLoading = false;
    notifyListeners();
  }

  /// Fetch Categories from API
  Future<void> fetchCategories() async {
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(ApiUrls.categoryList),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data["status"] == true && data["data"] is List) {
          categories = (data["data"] as List).map<Map<String, String>>((item) {
            return {
              "id": item["category_id"]?.toString() ?? "",
              "title": item["category_name"]?.toString() ?? "",
              "logo": item["logo"]?.toString() ?? "",
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("HOME CATEGORY API ERROR ❌ $e");
    }

    isCategoriesLoading = false;
    notifyListeners();
  }

  /// Fetch Recent Products from API
  Future<void> fetchRecentProducts() async {
    isProductsLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.productList}?page=1&limit=10'),
      );

      if (response.statusCode == 200) {
        final productResponse = ProductListResponse.fromJson(
          jsonDecode(response.body),
        );

        if (productResponse.status) {
          recentProducts = productResponse.data;
          debugPrint("RECENT PRODUCTS ✅ Fetched ${recentProducts.length} products");
        }
      }
    } catch (e) {
      debugPrint("RECENT PRODUCTS API ERROR ❌ $e");
    }

    isProductsLoading = false;
    notifyListeners();
  }

  void _startAutoScroll() {
    _timer?.cancel(); // Cancel any existing timer
    if (bannerImages.isEmpty) return;
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients && bannerImages.isNotEmpty) {
        _currentPage = (_currentPage + 1) % bannerImages.length;
        pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        notifyListeners();
      }
    });
  }

  /// Refresh Data (Pull-to-Refresh)
  Future<void> refresh() async {
    isCategoriesLoading = true;
    isProductsLoading = true;
    isSlidersLoading = true;
    categories.clear();
    recentProducts.clear();
    bannerImages.clear();
    notifyListeners();
    
    await Future.wait([
      fetchSliders(),
      fetchCategories(),
      fetchRecentProducts(),
    ]);

    _startAutoScroll(); // restart timer
  }

  /// Manually change page
  void changePage(int index) {
    _currentPage = index;
    if (pageController.hasClients) {
       pageController.animateToPage(
         _currentPage,
         duration: const Duration(milliseconds: 500),
         curve: Curves.easeInOut,
       );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }
}
