import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:inzaar/features/library/library_item.dart';

class LibraryRepository {
  Future<List<LibraryItem>> loadAllItems() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/library_catalog.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      List<LibraryItem> items = [];

      if (jsonData['books'] != null) {
        items.addAll(
          (jsonData['books'] as List)
              .map((e) => LibraryItem.fromJson(e))
              .toList(),
        );
      }
      if (jsonData['magazines'] != null) {
        items.addAll(
          (jsonData['magazines'] as List)
              .map((e) => LibraryItem.fromJson(e))
              .toList(),
        );
      }
      if (jsonData['articles'] != null) {
        items.addAll(
          (jsonData['articles'] as List)
              .map((e) => LibraryItem.fromJson(e))
              .toList(),
        );
      }

      return items;
    } catch (e) {
      debugPrint('Error loading catalog: $e');
      return [];
    }
  }

  Future<String> loadTextContent(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      return 'Error loading content: $e';
    }
  }
}
