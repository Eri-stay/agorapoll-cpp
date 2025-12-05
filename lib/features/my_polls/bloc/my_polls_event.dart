import 'package:equatable/equatable.dart';

abstract class MyPollsEvent extends Equatable {
  const MyPollsEvent();

  @override
  List<Object> get props => [];
}

// Event to load the My(user's) Polls
class LoadMyPolls extends MyPollsEvent {}
