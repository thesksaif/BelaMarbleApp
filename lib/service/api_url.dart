import '../core/api_config.dart';

class ApiUrls {
  static String get mainBaseUrl => ApiConfig.baseUrl;

  static String get categoryList => "$mainBaseUrl/category_list.php";
  static String get productList => "$mainBaseUrl/product_list.php";
  static String get search => "$mainBaseUrl/search.php";
  static String get webSetting => "$mainBaseUrl/websetting.php";
  static String get productDetails => "$mainBaseUrl/product_details.php";
  static String get sliderList => "$mainBaseUrl/slider_list.php";
}
