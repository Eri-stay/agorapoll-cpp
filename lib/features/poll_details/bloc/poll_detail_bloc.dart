import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/repository/auth_repository.dart';
import '../../shared/repositories/polls_repository.dart';
import 'poll_detail_event.dart';
import 'poll_detail_state.dart';

class PollDetailBloc extends Bloc<PollDetailEvent, PollDetailState> {
  final PollsRepository _pollsRepository;
  final AuthRepository _authRepository;
  StreamSubscription? _pollSubscription;

  PollDetailBloc({
    required PollsRepository pollsRepository,
    required AuthRepository authRepository,
  }) : _pollsRepository = pollsRepository,
       _authRepository = authRepository,
       super(PollDetailLoading()) {
    on<LoadPollDetails>(_onLoad);
    on<UpdateSelection>(_onUpdateSelection);
    on<SubmitVote>(_onSubmitVote);
    on<EnableRevote>(_onEnableRevote);
  }

  Future<void> _onLoad(
    LoadPollDetails event,
    Emitter<PollDetailState> emit,
  ) async {
    final userId = _authRepository.currentUserId;
    if (userId == null) {
      emit(const PollDetailError("User not authenticated"));
      return;
    }

    // Підписуємося на оновлення опитування
    await _pollSubscription?.cancel();
    _pollSubscription = _pollsRepository.getPollStream(event.pollId).listen((
      poll,
    ) {
      if (poll != null && !isClosed) {}
    });

    // Отримуємо початковий стан даних
    try {
      // 1. Чекаємо першого значення зі стріму
      final poll = await _pollsRepository.getPollStream(event.pollId).first;

      if (poll == null) {
        emit(const PollDetailError("Poll not found"));
        return;
      }

      // 2. Перевіряємо, чи юзер голосував
      final userVote = await _pollsRepository.getUserVote(event.pollId, userId);
      final hasVoted = userVote.isNotEmpty;

      emit(
        PollDetailLoaded(
          poll: poll,
          hasVoted: hasVoted,
          submittedSelection: userVote,
          currentSelection: hasVoted
              ? userVote
              : [], // Якщо голосував - показуємо вибір
          isAuthor: poll.creatorId == userId,
        ),
      );
    } catch (e) {
      emit(PollDetailError(e.toString()));
    }
  }

  void _onUpdateSelection(
    UpdateSelection event,
    Emitter<PollDetailState> emit,
  ) {
    if (state is PollDetailLoaded) {
      final currentState = state as PollDetailLoaded;
      List<String> newSelection = List.from(currentState.currentSelection);

      if (event.allowMultiple) {
        // Логіка чекбоксів
        if (newSelection.contains(event.option)) {
          newSelection.remove(event.option);
        } else {
          newSelection.add(event.option);
        }
      } else {
        // Логіка радіокнопок (тільки один вибір)
        newSelection = [event.option];
      }

      emit(currentState.copyWith(currentSelection: newSelection));
    }
  }

  Future<void> _onSubmitVote(
    SubmitVote event,
    Emitter<PollDetailState> emit,
  ) async {
    if (state is PollDetailLoaded) {
      final currentState = state as PollDetailLoaded;
      final userId = _authRepository.currentUserId;

      if (userId == null || currentState.currentSelection.isEmpty) return;

      emit(currentState.copyWith(isSubmitting: true));

      try {
        await _pollsRepository.vote(
          pollId: currentState.poll.id,
          userId: userId,
          selectedOptions: currentState.currentSelection,
        );

        emit(
          currentState.copyWith(
            isSubmitting: false,
            hasVoted: true,
            submittedSelection: currentState.currentSelection,
          ),
        );
      } catch (e) {
        // Повертаємо попередній стан, але прибираємо лоадер.
        // Помилку можна обробити окремим полем або Listener-ом в UI.
        emit(currentState.copyWith(isSubmitting: false));
      }
    }
  }

  void _onEnableRevote(EnableRevote event, Emitter<PollDetailState> emit) {
    if (state is PollDetailLoaded) {
      final currentState = state as PollDetailLoaded;
      // Дозволяємо редагувати (скидаємо прапорець hasVoted візуально, але зберігаємо submittedSelection)
      emit(currentState.copyWith(hasVoted: false));
    }
  }

  @override
  Future<void> close() {
    _pollSubscription?.cancel();
    return super.close();
  }
}
