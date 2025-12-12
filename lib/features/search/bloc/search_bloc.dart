import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/repositories/polls_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final PollsRepository _pollsRepository;

  SearchBloc({required PollsRepository pollsRepository})
    : _pollsRepository = pollsRepository,
      super(SearchInitial()) {
    on<SearchSubmitted>(_onSearchSubmitted);
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final poll = await _pollsRepository.findPollByCode(event.code);

      if (poll != null) {
        emit(SearchSuccess(poll.id));
      } else {
        emit(const SearchError("Poll with this code was not found."));
      }
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
