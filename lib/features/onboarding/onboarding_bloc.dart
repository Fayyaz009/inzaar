import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingPageChanged extends OnboardingEvent {
  final int page;

  const OnboardingPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

class OnboardingState extends Equatable {
  final int currentPage;

  const OnboardingState({required this.currentPage});

  factory OnboardingState.initial() => const OnboardingState(currentPage: 0);

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }

  @override
  List<Object?> get props => [currentPage];
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState.initial()) {
    on<OnboardingPageChanged>((event, emit) {
      emit(state.copyWith(currentPage: event.page));
    });
  }
}
