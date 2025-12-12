import 'package:equatable/equatable.dart';
import '../../../data/models/poll_model.dart';

abstract class MyPollsState extends Equatable {
  const MyPollsState();

  @override
  List<Object> get props => [];
}

// 1. Initial State (nothing loaded yet)
class MyPollsInitial extends MyPollsState {}

// 2. Loading State (show a spinner)
class MyPollsLoading extends MyPollsState {}

// 3. Success (show the list)
class MyPollsLoaded extends MyPollsState {
  final List<Poll> polls;

  const MyPollsLoaded({required this.polls});

  @override
  List<Object> get props => [polls];
}

// 4. Error (show the error message)
class MyPollsError extends MyPollsState {
  final String message;

  const MyPollsError({required this.message});

  @override
  List<Object> get props => [message];
}

class MyPollsActionFailed extends MyPollsLoaded {
  final String errorMessage;

  const MyPollsActionFailed({
    required super.polls, // Беремо список з попереднього стану
    required this.errorMessage,
  });

  @override
  List<Object> get props => [polls, errorMessage];
}
