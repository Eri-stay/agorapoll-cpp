import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'create_poll_event.dart';
import 'create_poll_state.dart';
import '../../../data/models/poll_model.dart';
import 'dart:math';
import '../../auth/repository/auth_repository.dart';
import '../../shared/repositories/polls_repository.dart';

class CreatePollBloc extends Bloc<CreatePollEvent, CreatePollState> {
  final AuthRepository _authRepository;
  final PollsRepository _pollsRepository;

  CreatePollBloc({
    required AuthRepository authRepository,
    required PollsRepository pollsRepository,
  }) : _authRepository = authRepository,
       _pollsRepository = pollsRepository,
       super(CreatePollInitial()) {
    on<CreatePollSubmitted>(_onSubmit);
  }

  // Poll code generator
  String _generatePollCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> _onSubmit(
    CreatePollSubmitted event,
    Emitter<CreatePollState> emit,
  ) async {
    emit(CreatePollLoading());

    try {
      final userId = _authRepository.currentUserId;

      if (userId == null) {
        emit(
          const CreatePollError("User not authenticated. Please log in again."),
        );
        return;
      }

      final String pollId = const Uuid().v4();

      // Create new Poll object
      final newPoll = Poll(
        id: pollId,
        creatorId: userId, // Used current user ID
        code: _generatePollCode(), // Generate poll code
        question: event.question,
        options: event.options,
        isAnonymous: event.isAnonymous,
        allowMultiple: event.allowMultiple,
        isChangeable: event.isChangeable,
        isClosed: false,
        createdAt: DateTime.now(),
      );

      // for ERROR testing (uncomment)
      // throw Exception("Failed to create poll. Try again.");

      await _pollsRepository.createPoll(newPoll);

      // if ok

      emit(CreatePollSuccess(pollId: newPoll.id, pollCode: newPoll.code));
    } catch (e) {
      emit(CreatePollError(e.toString()));
    }
  }
}
