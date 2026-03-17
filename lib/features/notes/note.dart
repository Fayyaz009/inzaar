import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final String itemId;
  final String quote;
  final DateTime timestamp;
  final String colorHex;

  const Note({
    required this.id,
    required this.itemId,
    required this.quote,
    required this.timestamp,
    required this.colorHex,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      itemId: map['item_id'] as String,
      quote: map['quote'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      colorHex: map['color_hex'] as String? ?? '#C49A53',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'quote': quote,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'color_hex': colorHex,
    };
  }

  @override
  List<Object?> get props => [id, itemId, quote, timestamp, colorHex];
}
