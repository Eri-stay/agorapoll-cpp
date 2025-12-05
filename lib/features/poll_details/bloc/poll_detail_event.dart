import 'package:equatable/equatable.dart';

abstract class PollDetailEvent extends Equatable {
  const PollDetailEvent();
  @override
  List<Object> get props => [];
}

// Load poll details after navigating to Poll Detail
class LoadPollDetails extends PollDetailEvent {
  final String pollId;
  const LoadPollDetails(this.pollId);
  @override
  List<Object> get props => [pollId];
}

// Update local selection (when user taps checkboxes but hasn't pressed Vote yet)
class UpdateSelection extends PollDetailEvent {
  final String option;
  final bool allowMultiple;
  const UpdateSelection(this.option, {required this.allowMultiple});
  @override
  List<Object> get props => [option, allowMultiple];
}

// Submit vote to the server
class SubmitVote extends PollDetailEvent {}

// Pressed "Change Vote"
class EnableRevote extends PollDetailEvent {}
