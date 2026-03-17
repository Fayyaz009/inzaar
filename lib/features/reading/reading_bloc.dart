import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReadingEvent extends Equatable {
  const ReadingEvent();

  @override
  List<Object?> get props => [];
}

class ReadingContentLoading extends ReadingEvent {
  const ReadingContentLoading();
}

class ReadingContentLoaded extends ReadingEvent {
  final List<String> paragraphs;
  final double savedProgress;

  const ReadingContentLoaded({
    required this.paragraphs,
    required this.savedProgress,
  });

  @override
  List<Object?> get props => [paragraphs, savedProgress];
}

class ReadingContentFailed extends ReadingEvent {
  final String message;

  const ReadingContentFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class ReadingControlsToggled extends ReadingEvent {
  const ReadingControlsToggled();
}

class ReadingControlsHidden extends ReadingEvent {
  const ReadingControlsHidden();
}

class ReadingState extends Equatable {
  final bool isLoading;
  final List<String> paragraphs;
  final double savedProgress;
  final bool showControls;
  final String? errorMessage;

  const ReadingState({
    required this.isLoading,
    required this.paragraphs,
    required this.savedProgress,
    required this.showControls,
    required this.errorMessage,
  });

  factory ReadingState.initial() => const ReadingState(
        isLoading: true,
        paragraphs: [],
        savedProgress: 0,
        showControls: false,
        errorMessage: null,
      );

  ReadingState copyWith({
    bool? isLoading,
    List<String>? paragraphs,
    double? savedProgress,
    bool? showControls,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReadingState(
      isLoading: isLoading ?? this.isLoading,
      paragraphs: paragraphs ?? this.paragraphs,
      savedProgress: savedProgress ?? this.savedProgress,
      showControls: showControls ?? this.showControls,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, paragraphs, savedProgress, showControls, errorMessage];
}

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  ReadingBloc() : super(ReadingState.initial()) {
    on<ReadingContentLoading>((event, emit) {
      emit(state.copyWith(isLoading: true, clearError: true));
    });

    on<ReadingContentLoaded>((event, emit) {
      emit(state.copyWith(
        isLoading: false,
        paragraphs: event.paragraphs,
        savedProgress: event.savedProgress,
        showControls: false,
        clearError: true,
      ));
    });

    on<ReadingContentFailed>((event, emit) {
      emit(state.copyWith(
        isLoading: false,
        paragraphs: [event.message],
        errorMessage: event.message,
      ));
    });

    on<ReadingControlsToggled>((event, emit) {
      emit(state.copyWith(showControls: !state.showControls));
    });

    on<ReadingControlsHidden>((event, emit) {
      if (!state.showControls) return;
      emit(state.copyWith(showControls: false));
    });
  }
}
