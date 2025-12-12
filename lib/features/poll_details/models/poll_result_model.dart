import 'package:equatable/equatable.dart';
import 'voter_model.dart';

class PollResult extends Equatable {
  final int totalVotes;
  final Map<String, OptionResult> resultsByOption; // Key: option text

  const PollResult({required this.totalVotes, required this.resultsByOption});

  @override
  List<Object?> get props => [totalVotes, resultsByOption];
}

class OptionResult extends Equatable {
  final String optionText;
  final int voteCount;
  final double percentage;
  final List<Voter> voters; // Will be empty for anonymous polls

  const OptionResult({
    required this.optionText,
    required this.voteCount,
    required this.percentage,
    required this.voters,
  });
  @override
  List<Object?> get props => [optionText, voteCount, percentage, voters];
}
