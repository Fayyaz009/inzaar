import 'package:equatable/equatable.dart';

enum ItemType { book, magazine, article }

class LibraryItem extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverPath;
  final String contentPath;
  final ItemType type;
  final bool isArabicRTL;
  final String? price;

  const LibraryItem({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverPath,
    required this.contentPath,
    required this.type,
    this.isArabicRTL = true,
    this.price,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    return LibraryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] ?? 'Abu Yahya',
      description: json['description'] ?? '',
      coverPath: json['coverPath'] as String,
      contentPath: json['contentPath'] as String,
      type: _parseType(json['type'] as String?),
      isArabicRTL: json['isArabicRTL'] as bool? ?? true,
      price: json['price'] as String?,
    );
  }

  static ItemType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'magazine':
        return ItemType.magazine;
      case 'article':
        return ItemType.article;
      case 'book':
      default:
        return ItemType.book;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        coverPath,
        contentPath,
        type,
        isArabicRTL,
        price
      ];
}
