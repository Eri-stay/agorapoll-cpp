import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object> get props => [];
}

class SearchSubmitted extends SearchEvent {
  final String code;
  const SearchSubmitted(this.code);
  @override
  List<Object> get props => [code];
}
