import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:inzaar/features/library/library_item.dart';
import 'package:inzaar/features/library/library_repository.dart';

// Events
abstract class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object> get props => [];
}

class LoadLibrary extends LibraryEvent {}

// States
abstract class LibraryState extends Equatable {
  const LibraryState();
  @override
  List<Object> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<LibraryItem> items;
  
  const LibraryLoaded({required this.items});

  List<LibraryItem> get books => items.where((i) => i.type == ItemType.book).toList();
  List<LibraryItem> get magazines => items.where((i) => i.type == ItemType.magazine).toList();
  List<LibraryItem> get articles => items.where((i) => i.type == ItemType.article).toList();
  List<LibraryItem> get abuYahyaBooks => books.where((i) => i.author == 'Abu Yahya').toList();
  List<LibraryItem> get otherBooks => books.where((i) => i.author != 'Abu Yahya').toList();

  @override
  List<Object> get props => [items];
}

class LibraryError extends LibraryState {
  final String message;
  const LibraryError({required this.message});
  @override
  List<Object> get props => [message];
}

// Bloc
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;

  LibraryBloc({required this.repository}) : super(LibraryInitial()) {
    on<LoadLibrary>((event, emit) async {
      emit(LibraryLoading());
      try {
        final items = await repository.loadAllItems();
        if (items.isEmpty) {
          emit(const LibraryError(message: "No items found in catalog."));
        } else {
          emit(LibraryLoaded(items: items));
        }
      } catch (e) {
        emit(LibraryError(message: e.toString()));
      }
    });
  }
}
