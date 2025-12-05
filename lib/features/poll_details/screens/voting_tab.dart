import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../bloc/poll_detail_bloc.dart';
import '../bloc/poll_detail_event.dart';
import '../bloc/poll_detail_state.dart';

class VotingTab extends StatelessWidget {
  final PollDetailLoaded state;

  const VotingTab({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poll = state.poll;
    final bool isReadOnly =
        state.hasVoted; // if already voted, make options read-only
    final bool canVote = state.currentSelection.isNotEmpty && !isReadOnly;

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

          // Options
          ...poll.options.map((option) {
            final isSelected = state.currentSelection.contains(option);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _OptionTile(
                text: option,
                isSelected: isSelected,
                isMultiple: poll.allowMultiple,
                onTap: isReadOnly
                    ? null // Disable tap if read-only
                    : () {
                        context.read<PollDetailBloc>().add(
                          UpdateSelection(
                            option,
                            allowMultiple: poll.allowMultiple,
                          ),
                        );
                      },
              ),
            );
          }),

          const SizedBox(height: 40),

          // Кнопки
          if (!state.hasVoted)
            PrimaryButton(
              text: state.isSubmitting ? "VOTING..." : "VOTE",
              onPressed: canVote
                  ? () {
                      context.read<PollDetailBloc>().add(SubmitVote());
                    }
                  : () {}, // Disabled functionality
              color: canVote ? AppColors.accentGold : AppColors.mutedGold,
            ),

          if (state.hasVoted) ...[
            Center(
              child: Text(
                "You have voted.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (poll.isChangeable)
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    context.read<PollDetailBloc>().add(EnableRevote());
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
                  label: const Text(
                    "Change Vote",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// Окремий віджет для гарної картки варіанту
class _OptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMultiple;
  final VoidCallback? onTap;

  const _OptionTile({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.isMultiple,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.accentGold
        : AppColors.optionInactive;
    final bgColor = isSelected
        ? const Color(0xFFF9F6F0)
        : AppColors.background; // F9F6F0 - very light gold

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Custom Checkbox/Radio Indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: isMultiple ? BoxShape.rectangle : BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGold
                      : AppColors.optionOutline,
                  width: 2,
                ),
                color: isSelected ? AppColors.accentGold : Colors.transparent,
                borderRadius: isMultiple ? BorderRadius.circular(4) : null,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
