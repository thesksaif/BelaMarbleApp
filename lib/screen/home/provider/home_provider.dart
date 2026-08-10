import 'dart:async';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/service/api_client.dart';
import 'package:bellamarble/service/api_url.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  /// Banner Controller
  final PageController pageController = PageController(
    viewportFraction: 0.88,
    initialPage: 0,
  ); // initialPage 0 is safer when loading dynamic data

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
    // All three endpoints are independent, so fire them together. Serialising
    // them made the slider request block categories and products for no reason.
    await Future.wait([
      fetchSliders(),
      fetchCategories(),
      fetchRecentProducts(),
    ]);
    _startAutoScroll(); // safe now that bannerImages is populated
  }

  /// Fetch Sliders from API
  Future<void> fetchSliders({bool forceRefresh = false}) async {
    isSlidersLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.getJson(
        ApiUrls.sliderList,
        forceRefresh: forceRefresh,
      );

      if (data["status"] == true && data["data"] is List) {
        bannerImages = (data["data"] as List)
            .map<String>((item) => item["image"].toString())
            .toList();
      }
    } catch (e) {
      debugPrint("HOME SLIDER API ERROR ❌ $e");
    }

    isSlidersLoading = false;
    notifyListeners();
  }

  /// Fetch Categories from API
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final data = await ApiClient.instance.getJson(
        ApiUrls.categoryList,
        forceRefresh: forceRefresh,
      );

      if (data["status"] == true && data["data"] is List) {
        categories = (data["data"] as List).map<Map<String, String>>((item) {
          return {
            "id": item["category_id"]?.toString() ?? "",
            "title": item["category_name"]?.toString() ?? "",
            "logo": item["logo"]?.toString() ?? "",
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("HOME CATEGORY API ERROR ❌ $e");
    }

    isCategoriesLoading = false;
    notifyListeners();
  }

  /// Fetch Recent Products from API
  Future<void> fetchRecentProducts({bool forceRefresh = false}) async {
    isProductsLoading = true;
    notifyListeners();

    try {
      final body = await ApiClient.instance.getJson(
        '${ApiUrls.productList}?page=1&limit=10',
        forceRefresh: forceRefresh,
      );
      final productResponse = ProductListResponse.fromJson(body);

      if (productResponse.status) {
        recentProducts = productResponse.data;
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
      fetchSliders(forceRefresh: true),
      fetchCategories(forceRefresh: true),
      fetchRecentProducts(forceRefresh: true),
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
