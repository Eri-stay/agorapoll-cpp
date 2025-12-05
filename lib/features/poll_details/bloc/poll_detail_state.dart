import 'package:equatable/equatable.dart';
import '../../../data/models/poll_model.dart';

abstract class PollDetailState extends Equatable {
  const PollDetailState();
  @override
  List<Object> get props => [];
}

class PollDetailLoading extends PollDetailState {}

class PollDetailError extends PollDetailState {
  final String message;
  const PollDetailError(this.message);
  @override
  List<Object> get props => [message];
}

class PollDetailLoaded extends PollDetailState {
  final Poll poll;
  final List<String> currentSelection; // UI
  final List<String> submittedSelection; // DB
  final bool hasVoted; // Whether the vote has been submitted
  final bool isSubmitting; // For spinner on the button
  final bool isAuthor; // Whether the current user is the author

  const PollDetailLoaded({
    required this.poll,
    this.currentSelection = const [],
    this.submittedSelection = const [],
    this.hasVoted = false,
    this.isSubmitting = false,
    this.isAuthor = false,
  });

  PollDetailLoaded copyWith({
    Poll? poll,
    List<String>? currentSelection,
    List<String>? submittedSelection,
    bool? hasVoted,
    bool? isSubmitting,
    bool? isAuthor,
  }) {
    return PollDetailLoaded(
      poll: poll ?? this.poll,
      currentSelection: currentSelection ?? this.currentSelection,
      submittedSelection: submittedSelection ?? this.submittedSelection,
      hasVoted: hasVoted ?? this.hasVoted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAuthor: isAuthor ?? this.isAuthor,
    );
  }

  @override
  List<Object> get props => [
    poll,
    currentSelection,
    submittedSelection,
    hasVoted,
    isSubmitting,
    isAuthor,
  ];
}
