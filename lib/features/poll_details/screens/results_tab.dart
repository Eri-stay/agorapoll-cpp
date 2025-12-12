import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/poll_detail_bloc.dart';
import '../bloc/poll_detail_event.dart';
import '../bloc/poll_detail_state.dart';
import '../models/poll_result_model.dart';
import '../models/voter_model.dart';

class ResultsTab extends StatefulWidget {
  final PollDetailLoaded initialState;
  const ResultsTab({Key? key, required this.initialState}) : super(key: key);

  @override
  State<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<ResultsTab> {
  @override
  void initState() {
    super.initState();
    context.read<PollDetailBloc>().add(LoadPollResults());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PollDetailBloc, PollDetailState>(
      buildWhen: (previous, current) {
        // return current is PollResultsLoading ||
        //     current is PollResultsLoaded ||
        //     current is PollDetailError;
        print(
          "BuildWhen fired. Previous: $previous, Current: $current",
        ); //qwerty
        return true;
      },
      builder: (context, state) {
        print("Builder fired with state: $state"); //qwerty
        if (state is PollResultsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.accentGold),
                SizedBox(height: 16),
                Text(
                  "Counting the ballots...",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (state is PollResultsLoaded) {
          return _ResultsView(state: state);
        }

        // Поки вантажиться, можна показати скелет або просто питання
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            widget.initialState.poll.question.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}

class _ResultsView extends StatelessWidget {
  final PollResultsLoaded state;
  const _ResultsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final poll = state.poll;
    final results = state.pollResult;

    if (results.totalVotes == 0) {
      return const Center(
        child: Text(
          "No votes have been cast yet.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Питання
          Text(
            poll.question.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 20,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          ...poll.options.map((optionText) {
            final optionResult = results.resultsByOption[optionText]!;
            final didIVoteForThis = state.myVote.contains(optionText);
            return _ResultSummaryBar(
              result: optionResult,
              didIVoteForThis: didIVoteForThis,
            );
          }).toList(),

          if (!poll.isAnonymous) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            ...poll.options.map((optionText) {
              final optionResult = results.resultsByOption[optionText]!;
              if (optionResult.voteCount == 0) return const SizedBox.shrink();
              return _DetailedResultSection(result: optionResult);
            }).toList(),
          ],
        ],
      ),
    );
  }
}

// Віджет для прогрес-бару
class _ResultSummaryBar extends StatelessWidget {
  final OptionResult result;
  final bool didIVoteForThis;
  const _ResultSummaryBar({
    required this.result,
    required this.didIVoteForThis,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (didIVoteForThis)
                const Icon(Icons.check, color: AppColors.accentGold, size: 20),
              if (didIVoteForThis) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.optionText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "${(result.percentage * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: result.percentage,
            backgroundColor: AppColors.mutedGold.withOpacity(0.2),
            color: AppColors.mutedGold,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// Віджет для секції з аватарами
class _DetailedResultSection extends StatelessWidget {
  final OptionResult result;
  const _DetailedResultSection({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${result.optionText} · ${(result.percentage * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                "${result.voteCount} vote${result.voteCount == 1 ? '' : 's'}",
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.voters.map((voter) => _VoterTile(voter: voter)),
        ],
      ),
    );
  }
}

// Віджет для рядка з аватаром
class _VoterTile extends StatelessWidget {
  final Voter voter;
  const _VoterTile({required this.voter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: voter.avatarColor,
            child: Text(
              voter.displayName.isNotEmpty
                  ? voter.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(voter.displayName, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
