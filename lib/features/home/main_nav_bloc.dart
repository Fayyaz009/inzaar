import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MainNavEvent extends Equatable {
  const MainNavEvent();

  @override
  List<Object?> get props => [];
}

class MainNavTabSelected extends MainNavEvent {
  final int index;

  const MainNavTabSelected(this.index);

  @override
  List<Object?> get props => [index];
}

class MainNavBackPressed extends MainNavEvent {
  const MainNavBackPressed();
}

class MainNavState extends Equatable {
  final int currentIndex;
  final List<int> history;

  const MainNavState({
    required this.currentIndex,
    required this.history,
  });

  factory MainNavState.initial() => const MainNavState(
        currentIndex: 0,
        history: [0],
      );

  bool get canPopTabHistory => history.length > 1;

  MainNavState copyWith({
    int? currentIndex,
    List<int>? history,
  }) {
    return MainNavState(
      currentIndex: currentIndex ?? this.currentIndex,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [currentIndex, history];
}

class MainNavBloc extends Bloc<MainNavEvent, MainNavState> {
  MainNavBloc() : super(MainNavState.initial()) {
    on<MainNavTabSelected>(_onTabSelected);
    on<MainNavBackPressed>(_onBackPressed);
  }

  void _onTabSelected(MainNavTabSelected event, Emitter<MainNavState> emit) {
    if (event.index == state.currentIndex) return;

    final updatedHistory = List<int>.from(state.history)..add(event.index);
    emit(state.copyWith(currentIndex: event.index, history: updatedHistory));
  }

  void _onBackPressed(MainNavBackPressed event, Emitter<MainNavState> emit) {
    if (!state.canPopTabHistory) return;

    final updatedHistory = List<int>.from(state.history)..removeLast();
    emit(state.copyWith(
      currentIndex: updatedHistory.last,
      history: updatedHistory,
    ));
  }
}
