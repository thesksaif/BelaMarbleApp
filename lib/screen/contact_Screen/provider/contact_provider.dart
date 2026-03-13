import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/models/web_setting_model.dart';
import '../../../service/api_url.dart';

class ContactProvider extends ChangeNotifier {
  String email = "";
  String phone = "";
  String website = "";
  String location = "";
  bool isLoading = false;

  ContactProvider() {
    fetchContactInfo();
  }

  Future<void> fetchContactInfo() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiUrls.webSetting));

      if (response.statusCode == 200) {
        final settingResponse = WebSettingResponse.fromJson(jsonDecode(response.body));

        if (settingResponse.status && settingResponse.data != null) {
          final data = settingResponse.data!;
          email = data.email;
          phone = data.phone;
          website = data.website;
          location = data.address;
        }
      }
    } catch (e) {
      debugPrint("CONTACT API ERROR ❌ $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
