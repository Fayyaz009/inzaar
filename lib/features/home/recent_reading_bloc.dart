import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:inzaar/core/database_helper.dart';

abstract class RecentReadingEvent extends Equatable {
  const RecentReadingEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecentReading extends RecentReadingEvent {
  const LoadRecentReading();
}

class RecentReadingState extends Equatable {
  final String? itemId;
  final double progress;
  final bool isLoading;

  const RecentReadingState({
    required this.itemId,
    required this.progress,
    required this.isLoading,
  });

  factory RecentReadingState.initial() => const RecentReadingState(
        itemId: null,
        progress: 0,
        isLoading: true,
      );

  RecentReadingState copyWith({
    String? itemId,
    double? progress,
    bool? isLoading,
    bool clearItem = false,
  }) {
    return RecentReadingState(
      itemId: clearItem ? null : (itemId ?? this.itemId),
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [itemId, progress, isLoading];
}

class RecentReadingBloc extends Bloc<RecentReadingEvent, RecentReadingState> {
  RecentReadingBloc() : super(RecentReadingState.initial()) {
    on<LoadRecentReading>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      final progress = await DatabaseHelper.instance.getMostRecentProgress();
      if (progress == null) {
        emit(state.copyWith(isLoading: false, progress: 0, clearItem: true));
        return;
      }

      emit(
        state.copyWith(
          itemId: progress['id'] as String?,
          progress: (progress['scroll_percentage'] as num?)?.toDouble() ?? 0,
          isLoading: false,
        ),
      );
    });
  }
}
