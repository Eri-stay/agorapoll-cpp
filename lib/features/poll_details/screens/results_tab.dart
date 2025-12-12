import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/zig_zag_divider.dart';
import '../bloc/poll_detail_state.dart';
import '../models/poll_result_model.dart';
import '../models/voter_model.dart';

/// Віджет для вкладки "Results", який тепер є простим "тупим" віджетом.
/// Він лише відображає дані, які отримує зі стану `PollDetailLoaded`.
class ResultsTab extends StatelessWidget {
  final PollDetailLoaded state;
  const ResultsTab({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Показуємо спінер, якщо ввімкнено прапорець `isResultsLoading`.
    if (state.isResultsLoading) {
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

    // 2. Якщо результати ще не завантажені (тобто pollResult == null).
    // Це буде відображатися, поки користувач не перейде на цю вкладку вперше.
    if (state.pollResult == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            "The results will be loaded once you switch to this tab.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    // 3. Якщо результати завантажені, показуємо їх через `_ResultsView`.
    return _ResultsView(state: state);
  }
}

/// Внутрішній віджет для відображення завантажених результатів.
class _ResultsView extends StatelessWidget {
  final PollDetailLoaded state;
  const _ResultsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final poll = state.poll;
    // Тепер ми впевнені, що pollResult не є null, тому використовуємо `!`.
    final results = state.pollResult!;

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

          // Загальні результати (прогрес-бари)
          ...poll.options.map((optionText) {
            final optionResult = results.resultsByOption[optionText]!;
            final didIVoteForThis = state.submittedSelection.contains(
              optionText,
            );
            return _ResultSummaryBar(
              result: optionResult,
              didIVoteForThis: didIVoteForThis,
            );
          }).toList(),

          // Детальні результати (списки юзерів), якщо не анонімно
          if (!poll.isAnonymous) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: ZigZagDivider(),
            ),
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
