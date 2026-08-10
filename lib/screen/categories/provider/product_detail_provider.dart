import 'dart:convert';
import 'package:bellamarble/core/models/product_model.dart';
import 'package:bellamarble/service/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductDetailProvider extends ChangeNotifier {
  Product? product;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchProductDetails(String productId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.productDetails}?product_id=$productId'),
      );
      debugPrint(
        "PRODUCT DETAIL API: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detailResponse = ProductDetailResponse.fromJson(data);
        if (detailResponse.status) {
          product = detailResponse.data;
        } else {
          errorMessage = detailResponse.message;
        }
      } else {
        errorMessage = 'Failed to load product details';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      debugPrint("PRODUCT DETAIL ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void setInitialProduct(Product initialProduct) {
    product = initialProduct;
    // We update UI immediately with initial data
  }
}
