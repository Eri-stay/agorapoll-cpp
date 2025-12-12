import 'package:equatable/equatable.dart';
import '../../../data/models/poll_model.dart';
import '../models/poll_result_model.dart';

abstract class PollDetailState extends Equatable {
  const PollDetailState();
  @override
  List<Object?> get props => [];
}

class PollDetailLoading extends PollDetailState {}

class PollDetailError extends PollDetailState {
  final String message;
  const PollDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- ЦЕ ТЕПЕР НАШ ЄДИНИЙ СТАН З ДАНИМИ ---
class PollDetailLoaded extends PollDetailState {
  final Poll poll;
  final List<String> currentSelection;
  final List<String> submittedSelection;
  final bool hasVoted;
  final bool isSubmitting;
  final bool isAuthor;

  // --- НОВІ ПОЛЯ ---
  final bool isResultsLoading; // Прапорець завантаження результатів
  final PollResult? pollResult; // Результати (можуть бути null)

  const PollDetailLoaded({
    required this.poll,
    this.currentSelection = const [],
    this.submittedSelection = const [],
    this.hasVoted = false,
    this.isSubmitting = false,
    this.isAuthor = false,
    this.isResultsLoading = false, // За замовчуванням
    this.pollResult, // За замовчуванням null
  });

  PollDetailLoaded copyWith({
    Poll? poll,
    List<String>? currentSelection,
    List<String>? submittedSelection,
    bool? hasVoted,
    bool? isSubmitting,
    bool? isAuthor,
    bool? isResultsLoading,
    PollResult? pollResult,
  }) {
    return PollDetailLoaded(
      poll: poll ?? this.poll,
      currentSelection: currentSelection ?? this.currentSelection,
      submittedSelection: submittedSelection ?? this.submittedSelection,
      hasVoted: hasVoted ?? this.hasVoted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAuthor: isAuthor ?? this.isAuthor,
      isResultsLoading: isResultsLoading ?? this.isResultsLoading,
      pollResult: pollResult ?? this.pollResult,
    );
  }

  @override
  List<Object?> get props => [
    poll,
    currentSelection,
    submittedSelection,
    hasVoted,
    isSubmitting,
    isAuthor,
    isResultsLoading,
    pollResult,
  ];
}

// ВИДАЛЯЄМО ЦІ КЛАСИ:
// class PollResultsLoading extends PollDetailState {}
// class PollResultsLoaded extends PollDetailState {}
