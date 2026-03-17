import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inzaar/core/database_helper.dart';
import 'package:inzaar/features/notes/note.dart';
import 'package:inzaar/features/notes/notes_event.dart';
import 'package:inzaar/features/notes/notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final DatabaseHelper dbHelper;

  NotesBloc({required this.dbHelper}) : super(NotesInitial()) {
    on<LoadAllNotes>(_onLoadAllNotes);
    on<LoadNotesForItem>(_onLoadNotesForItem);
    on<AddNote>(_onAddNote);
    on<DeleteNote>(_onDeleteNote);
  }

  Future<void> _onLoadAllNotes(
      LoadAllNotes event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final maps = await dbHelper.getAllNotes();
      final notes = maps.map((map) => Note.fromMap(map)).toList();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('Failed to load notes: $e'));
    }
  }

  Future<void> _onLoadNotesForItem(
      LoadNotesForItem event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final maps = await dbHelper.getNotesForItem(event.itemId);
      final notes = maps.map((map) => Note.fromMap(map)).toList();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('Failed to load notes for item: $e'));
    }
  }

  Future<void> _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      await dbHelper.insertNote(event.itemId, event.quote, event.colorHex);
      add(const LoadAllNotes());
    } catch (e) {
      emit(NotesError('Failed to add note: $e'));
    }
  }

  Future<void> _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await dbHelper.deleteNote(event.id);
      add(const LoadAllNotes());
    } catch (e) {
      emit(NotesError('Failed to delete note: $e'));
    }
  }
}
