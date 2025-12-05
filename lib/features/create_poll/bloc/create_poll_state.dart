import 'package:equatable/equatable.dart';

abstract class CreatePollState extends Equatable {
  const CreatePollState();
  @override
  List<Object> get props => [];
}

class CreatePollInitial extends CreatePollState {}

class CreatePollLoading extends CreatePollState {}

class CreatePollSuccess extends CreatePollState {
  final String pollId;
  final String pollCode;

  const CreatePollSuccess({required this.pollId, required this.pollCode});

  @override
  List<Object> get props => [pollId, pollCode];
}

class CreatePollError extends CreatePollState {
  final String error;
  const CreatePollError(this.error);
  @override
  List<Object> get props => [error];
}
