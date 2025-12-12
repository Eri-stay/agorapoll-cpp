import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/repository/auth_repository.dart';
import '../../shared/repositories/polls_repository.dart';
import '../models/poll_result_model.dart';
import '../models/voter_model.dart';
import 'poll_detail_event.dart';
import 'poll_detail_state.dart';

class PollDetailBloc extends Bloc<PollDetailEvent, PollDetailState> {
  final PollsRepository _pollsRepository;
  final AuthRepository _authRepository;
  StreamSubscription? _pollSubscription;
  StreamSubscription? _votesSubscription;

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
    on<LoadPollResults>(_onLoadResults);
    on<PollResultsUpdated>(_onResultsUpdated);
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
      if (poll != null && !isClosed) {
        // Can update poll details in state if title etc. changed.
      }
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

  Future<void> _onLoadResults(
    LoadPollResults event,
    Emitter<PollDetailState> emit,
  ) async {
    if (state is! PollDetailLoaded) return;
    final currentState = state as PollDetailLoaded;

    // Вмикаємо прапорець завантаження
    emit(currentState.copyWith(isResultsLoading: true));

    await _votesSubscription?.cancel();
    _votesSubscription = _pollsRepository
        .getVotesStream(currentState.poll.id)
        .listen((snapshot) {
          add(
            PollResultsUpdated(
              votesSnapshot: snapshot,
              poll: currentState.poll,
              myVote: currentState.submittedSelection,
            ),
          );
        });
  }

  Future<void> _onResultsUpdated(
    PollResultsUpdated event,
    Emitter<PollDetailState> emit,
  ) async {
    if (state is! PollDetailLoaded) return;
    final currentState = state as PollDetailLoaded;

    final poll = event.poll;
    final myVote = event.myVote;

    final votes = event.votesSnapshot.docs;
    final totalVotes = votes.length;
    Map<String, OptionResult> resultsByOption = {};

    // 1. Ініціалізація
    for (var option in poll.options) {
      resultsByOption[option] = OptionResult(
        optionText: option,
        voteCount: 0,
        percentage: 0.0,
        voters: [],
      );
    }

    // 2. Підрахунок голосів
    for (var vote in votes) {
      final data = vote.data() as Map<String, dynamic>;
      final List<String> selected = List<String>.from(
        data['selectedOptions'] ?? [],
      );
      for (var option in selected) {
        if (resultsByOption.containsKey(option)) {
          final oldResult = resultsByOption[option]!;
          resultsByOption[option] = OptionResult(
            optionText: option,
            voteCount: oldResult.voteCount + 1,
            percentage: 0.0,
            voters: oldResult.voters,
          );
        }
      }
    }

    // 3. Завантаження даних юзерів (якщо потрібно)
    if (!poll.isAnonymous) {
      List<Future> userFutures = [];
      Map<String, DocumentSnapshot> userDataCache = {};

      for (var vote in votes) {
        userFutures.add(
          _pollsRepository
              .getUserData(vote.id)
              .then((doc) {
                // Put user data into cache only if exists
                if (doc.exists) {
                  userDataCache[vote.id] = doc;
                }
              })
              .catchError((error) {
                print('Failed to load user data for ${vote.id}: $error');
              }),
        );
      }

      await Future.wait(userFutures);

      for (var vote in votes) {
        final userId = vote.id;
        final userDoc = userDataCache[userId];
        if (userDoc != null && userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final voter = Voter(
            id: userId,
            displayName: userData['displayName'] ?? 'N/A',
            avatarColor: Color(userData['avatarColor'] ?? Colors.grey.value),
          );
          final List<String> selected = List<String>.from(
            (vote.data() as Map<String, dynamic>)['selectedOptions'] ?? [],
          );
          for (var option in selected) {
            if (resultsByOption.containsKey(option)) {
              final oldResult = resultsByOption[option]!;

              final newVoters = List<Voter>.from(oldResult.voters)..add(voter);

              resultsByOption[option] = OptionResult(
                optionText: oldResult.optionText,
                voteCount: oldResult.voteCount,
                percentage: oldResult.percentage,
                voters: newVoters,
              );
            }
          }
        }
      }
    }

    // 4. Розрахунок відсотків
    final finalResultsByOption = <String, OptionResult>{};
    resultsByOption.forEach((optionText, result) {
      final percentage = totalVotes > 0 ? result.voteCount / totalVotes : 0.0;
      finalResultsByOption[optionText] = OptionResult(
        optionText: result.optionText,
        voteCount: result.voteCount,
        percentage: percentage,
        voters: result.voters,
      );
    });

    final finalResult = PollResult(
      totalVotes: totalVotes,
      resultsByOption: finalResultsByOption,
    );

    // 5. Випускаємо фінальний стан
    emit(
      currentState.copyWith(
        pollResult: finalResult,
        isResultsLoading: false, // Вимикаємо прапорець завантаження
      ),
    );
  }

  @override
  Future<void> close() {
    _pollSubscription?.cancel();
    _votesSubscription?.cancel();
    return super.close();
  }
}
