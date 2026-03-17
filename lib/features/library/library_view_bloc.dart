import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LibraryViewEvent extends Equatable {
  const LibraryViewEvent();

  @override
  List<Object?> get props => [];
}

class LibraryGridViewToggled extends LibraryViewEvent {
  const LibraryGridViewToggled();
}

class LibraryGridViewSet extends LibraryViewEvent {
  final bool isGridView;

  const LibraryGridViewSet(this.isGridView);

  @override
  List<Object?> get props => [isGridView];
}

class LibraryViewState extends Equatable {
  final bool isGridView;

  const LibraryViewState({required this.isGridView});

  factory LibraryViewState.initial() => const LibraryViewState(isGridView: false);

  LibraryViewState copyWith({bool? isGridView}) {
    return LibraryViewState(isGridView: isGridView ?? this.isGridView);
  }

  @override
  List<Object?> get props => [isGridView];
}

class LibraryViewBloc extends Bloc<LibraryViewEvent, LibraryViewState> {
  LibraryViewBloc() : super(LibraryViewState.initial()) {
    on<LibraryGridViewToggled>((event, emit) {
      emit(state.copyWith(isGridView: !state.isGridView));
    });
    on<LibraryGridViewSet>((event, emit) {
      emit(state.copyWith(isGridView: event.isGridView));
    });
  }
}
