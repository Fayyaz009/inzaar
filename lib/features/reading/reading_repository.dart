import 'package:flutter/services.dart';

class ReadingRepository {
  Future<String> loadTextContent(String assetPath) async {
    try {
      // Small delay just to show loading state if needed
      await Future.delayed(const Duration(milliseconds: 300));
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      return 'Error loading content from $assetPath. Please ensure the book is downloaded properly.';
    }
  }
}
