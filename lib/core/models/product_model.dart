class ProductListResponse {
  final bool status;
  final int code;
  final String message;
  final Pagination pagination;
  final List<Product> data;

  ProductListResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class Pagination {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int limit;

  Pagination({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalRecords: json['total_records'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      limit: json['limit'] ?? 12,
    );
  }
}

class Product {
  final int productId;
  final int categoryId;
  final String name;
  final String size;
  final String description;
  final String tags;
  final String quantity;
  final String price;
  final String availability;
  final int position;
  final String image;
  final String createdAt;

  Product({
    required this.productId,
    required this.categoryId,
    required this.name,
    required this.size,
    required this.description,
    required this.tags,
    required this.quantity,
    required this.price,
    required this.availability,
    required this.position,
    required this.image,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      description: json['description'] ?? '',
      tags: json['tags'] ?? '',
      quantity: json['quantity'] ?? '',
      price: json['price'] ?? '',
      availability: json['availability'] ?? '',
      position: json['position'] ?? 0,
      image: json['image'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ProductDetailResponse {
  final bool status;
  final int code;
  final String message;
  final Product data;

  ProductDetailResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: Product.fromJson(json['data'] ?? {}),
    );
  }
}
