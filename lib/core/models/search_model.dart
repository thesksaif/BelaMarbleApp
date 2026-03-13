class SearchResponse {
  final bool status;
  final int code;
  final String message;
  final String keyword;
  final SearchTotal total;
  final SearchData data;

  SearchResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.keyword,
    required this.total,
    required this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      keyword: json['keyword'] ?? '',
      total: SearchTotal.fromJson(json['total'] ?? {}),
      data: SearchData.fromJson(json['data'] ?? {}),
    );
  }
}

class SearchTotal {
  final int categories;
  final int products;

  SearchTotal({
    required this.categories,
    required this.products,
  });

  factory SearchTotal.fromJson(Map<String, dynamic> json) {
    return SearchTotal(
      categories: json['categories'] ?? 0,
      products: json['products'] ?? 0,
    );
  }
}

class SearchData {
  final List<SearchCategory> categories;
  final List<SearchProduct> products;

  SearchData({
    required this.categories,
    required this.products,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((item) => SearchCategory.fromJson(item))
              .toList() ??
          [],
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => SearchProduct.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class SearchCategory {
  final int categoryId;
  final String categoryName;
  final String logo;

  SearchCategory({
    required this.categoryId,
    required this.categoryName,
    required this.logo,
  });

  factory SearchCategory.fromJson(Map<String, dynamic> json) {
    return SearchCategory(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }
}

class SearchProduct {
  final int productId;
  final int categoryId;
  final String name;
  final String price;
  final String image;
  final String availability;

  SearchProduct({
    required this.productId,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.image,
    required this.availability,
  });

  factory SearchProduct.fromJson(Map<String, dynamic> json) {
    return SearchProduct(
      productId: json['product_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      image: json['image'] ?? '',
      availability: json['availability'] ?? '',
    );
  }
}
