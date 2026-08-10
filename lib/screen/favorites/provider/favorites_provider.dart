import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class FavoritesProvider extends ChangeNotifier {
  // 🔹 All tiles
  final List<Map<String, String>> tiles = [
    {
      "title": "2/4 Distal & Mat",
      "image": "assets/title/ezgif.com-webp-to-jpg-10.webp",
    },
    {
      "title": "Luxury Marble",
      "image": "assets/title/luxurious-marble-for-your-home.jpg",
    },
    {
      "title": "Floor Tiles",
      "image": "assets/title/marble-floor-tiles-548.jpg",
    },
  ];

  List<Map<String, String>> filteredTiles = [];

  final TextEditingController searchController = TextEditingController();

  // 🎤 Speech
  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;

  FavoritesProvider() {
    filteredTiles = tiles;
  }

  // 🔍 Search
  void onSearch(String value) {
    filteredTiles = tiles
        .where(
          (tile) => tile["title"]!.toLowerCase().contains(value.toLowerCase()),
        )
        .toList();
    notifyListeners();
  }

  // 🎤 Start Mic
  Future<void> startListening() async {
    bool available = await speech.initialize();

    if (available) {
      isListening = true;
      notifyListeners();

      speech.listen(
        onResult: (result) {
          final text = result.recognizedWords;
          searchController.text = text;
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
          onSearch(text);
        },
      );
    }
  }

  // 🎤 Stop Mic
  void stopListening() {
    speech.stop();
    isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    speech.stop();
    super.dispose();
  }
}
