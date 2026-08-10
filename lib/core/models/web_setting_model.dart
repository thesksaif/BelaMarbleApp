class WebSettingModel {
  final String email;
  final String phone;
  final String website;
  final String address;

  WebSettingModel({
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
  });

  factory WebSettingModel.fromJson(Map<String, dynamic> json) {
    return WebSettingModel(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      website: json['web_url'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class WebSettingResponse {
  final bool status;
  final String message;
  final WebSettingModel? data;

  WebSettingResponse({required this.status, required this.message, this.data});

  factory WebSettingResponse.fromJson(Map<String, dynamic> json) {
    return WebSettingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? WebSettingModel.fromJson(json['data'])
          : null,
    );
  }
}
