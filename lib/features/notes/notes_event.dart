import 'package:equatable/equatable.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllNotes extends NotesEvent {
  const LoadAllNotes();
}

class LoadNotesForItem extends NotesEvent {
  final String itemId;
  const LoadNotesForItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class AddNote extends NotesEvent {
  final String itemId;
  final String quote;
  final String colorHex;

  const AddNote({required this.itemId, required this.quote, required this.colorHex});

  @override
  List<Object?> get props => [itemId, quote, colorHex];
}

class DeleteNote extends NotesEvent {
  final int id;
  final String? itemIdContext;

  const DeleteNote({required this.id, this.itemIdContext});

  @override
  List<Object?> get props => [id, itemIdContext];
}
