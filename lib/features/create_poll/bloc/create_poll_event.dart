import 'package:equatable/equatable.dart';

abstract class CreatePollEvent extends Equatable {
  const CreatePollEvent();
  @override
  List<Object> get props => [];
}

class CreatePollSubmitted extends CreatePollEvent {
  final String question;
  final List<String> options;
  final bool isAnonymous;
  final bool allowMultiple;
  final bool isChangeable;

  const CreatePollSubmitted({
    required this.question,
    required this.options,
    required this.isAnonymous,
    required this.allowMultiple,
    required this.isChangeable,
  });

  @override
  List<Object> get props => [
    question,
    options,
    isAnonymous,
    allowMultiple,
    isChangeable,
  ];
}

// to do: ask if user wants to quit without saving
