import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/poll_model.dart';

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

class PollResultsUpdated extends PollDetailEvent {
  final QuerySnapshot votesSnapshot;
  final Poll poll;
  final List<String> myVote;

  const PollResultsUpdated({
    required this.votesSnapshot,
    required this.poll,
    required this.myVote,
  });

  @override
  List<Object> get props => [votesSnapshot, poll, myVote];
}

// Submit vote to the server
class SubmitVote extends PollDetailEvent {}

// Pressed "Change Vote"
class EnableRevote extends PollDetailEvent {}

//Load poll results
class LoadPollResults extends PollDetailEvent {}

class DeletePoll extends PollDetailEvent {}

class TogglePollStatus extends PollDetailEvent {}
