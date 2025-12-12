import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_polls_event.dart';
import 'my_polls_state.dart';
import '../../shared/repositories/polls_repository.dart';
import '../../auth/repository/auth_repository.dart';
import '../../shared/repositories/polls_repository.dart';
import '../../auth/repository/auth_repository.dart';

class MyPollsBloc extends Bloc<MyPollsEvent, MyPollsState> {
  final PollsRepository _pollsRepository;
  final AuthRepository _authRepository;

  MyPollsBloc({
    required PollsRepository pollsRepository,
    required AuthRepository authRepository,
  }) : _pollsRepository = pollsRepository,
       _authRepository = authRepository,
       super(MyPollsInitial()) {
    on<LoadMyPolls>(_onLoadMyPolls);
    on<DeletePollFromList>(_onDeletePoll);
    on<TogglePollStatusFromList>(_onTogglePollStatus);
  }

  Future<void> _onLoadMyPolls(
    LoadMyPolls event,
    Emitter<MyPollsState> emit,
  ) async {
    // Load screen first
    emit(MyPollsLoading());

    final userId = _authRepository.currentUserId;
    if (userId == null) {
      emit(const MyPollsError(message: "User not found"));
      return;
    }

    try {
      // ERROR for testing (uncomment)
      // throw Exception("Failed to connect to Agora server");

      print("??? Fetching polls for userId: $userId");
      await emit.forEach(
        _pollsRepository.getMyPolls(userId),
        onData: (polls) {
          return MyPollsLoaded(polls: polls);
        },
        onError: (error, stackTrace) {
          print("error: $error");
          return MyPollsError(message: error.toString());
        },
      );
    } catch (e) {
      print("error: $e");
      emit(MyPollsError(message: e.toString()));
    }
  }

  Future<void> _onDeletePoll(
    DeletePollFromList event,
    Emitter<MyPollsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MyPollsLoaded) return;
    try {
      await _pollsRepository.deletePoll(event.pollId);
    } catch (e) {
      emit(
        MyPollsActionFailed(
          polls: currentState.polls,
          errorMessage: "Failed to delete poll. Please try again.",
        ),
      );
    }
  }

  Future<void> _onTogglePollStatus(
    TogglePollStatusFromList event,
    Emitter<MyPollsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MyPollsLoaded) return;

    try {
      await _pollsRepository.updatePoll(event.pollId, {
        'isClosed': !event.currentStatus,
      });
      // UI оновиться сам через стрім
    } catch (e) {
      emit(
        MyPollsActionFailed(
          polls: currentState.polls,
          errorMessage: "Failed to update poll status. Please try again.",
        ),
      );
    }
  }
}
