import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_poll_event.dart';
import 'create_poll_state.dart';
import '../../../data/models/poll_model.dart';
import 'dart:math';
import '../../auth/repository/auth_repository.dart';

class CreatePollBloc extends Bloc<CreatePollEvent, CreatePollState> {
  final AuthRepository _authRepository;

  CreatePollBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(CreatePollInitial()) {
    on<CreatePollSubmitted>(_onSubmit);
  }

  // Poll code generator
  String _generatePollCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
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

      // Create new Poll object
      final newPoll = Poll(
        id: UniqueKey().toString(),
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

      // to do: save newPoll to database
      print("Saving poll to DB: ${newPoll.question} with code ${newPoll.code}");

      // for ERROR testing (uncomment)
      // throw Exception("Failed to create poll. Try again.");

      // if ok

      emit(CreatePollSuccess(pollId: newPoll.id, pollCode: newPoll.code));
    } catch (e) {
      emit(CreatePollError(e.toString()));
    }
  }
}
