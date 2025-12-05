import 'package:flutter_bloc/flutter_bloc.dart';
import 'my_polls_event.dart';
import 'my_polls_state.dart';
import '../data/mock_polls.dart';

class MyPollsBloc extends Bloc<MyPollsEvent, MyPollsState> {
  MyPollsBloc() : super(MyPollsInitial()) {
    on<LoadMyPolls>(_onLoadMyPolls);
  }

  Future<void> _onLoadMyPolls(
    LoadMyPolls event,
    Emitter<MyPollsState> emit,
  ) async {
    // Load screen first
    emit(MyPollsLoading());

    try {
      // Simulate a server request
      await Future.delayed(const Duration(seconds: 2));

      // ERROR for testing (uncomment)
      // throw Exception("Failed to connect to Agora server");

      // If ok — mockPolls
      emit(MyPollsLoaded(polls: mockPolls));
    } catch (e) {
      // If error — return error state
      emit(MyPollsError(message: e.toString()));
    }
  }
}
