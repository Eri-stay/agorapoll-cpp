import 'package:equatable/equatable.dart';

abstract class MyPollsEvent extends Equatable {
  const MyPollsEvent();

  @override
  List<Object> get props => [];
}

// Event to load the My(user's) Polls
class LoadMyPolls extends MyPollsEvent {}

class DeletePollFromList extends MyPollsEvent {
  final String pollId;
  const DeletePollFromList(this.pollId);

  @override
  List<Object> get props => [pollId];
}

class TogglePollStatusFromList extends MyPollsEvent {
  final String pollId;
  final bool currentStatus;
  const TogglePollStatusFromList({
    required this.pollId,
    required this.currentStatus,
  });

  @override
  List<Object> get props => [pollId, currentStatus];
}
