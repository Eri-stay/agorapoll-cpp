import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_polls_event.dart';
import 'my_polls_state.dart';
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
}
