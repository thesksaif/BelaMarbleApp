class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String logo;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.logo,
  });

  /// 📥 FROM JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  /// 📤 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'logo': logo,
    };
  }
}

/// 📦 API RESPONSE MODEL
class CategoryResponse {
  final bool status;
  final int code;
  final String message;
  final List<CategoryModel> data;

  CategoryResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  /// 📥 FROM JSON
  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => CategoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
