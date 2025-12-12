import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/poll_model.dart';
import '../../poll_details/screens/poll_details_screen.dart';
import '../../shared/widgets/poll_action_menu.dart';
import '../bloc/my_polls_bloc.dart';
import '../bloc/my_polls_event.dart';

class PollCard extends StatelessWidget {
  final Poll poll;

  const PollCard({Key? key, required this.poll}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // content opacity for Closed polls
    final double contentOpacity = poll.isClosed ? 0.5 : 1.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PollDetailsScreen(pollId: poll.id)),
        );
      },

      child: Card(
        elevation: 0,
        color: AppColors.cardBackground,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.cardOutline, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Іконка замка для закритих опитувань
              if (poll.isClosed)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.lock_outline,
                    color: AppColors.textSecondary.withValues(
                      alpha: contentOpacity,
                    ),
                  ),
                ),

              // Текст питання
              Expanded(
                child: Text(
                  poll.question,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: AppColors.textPrimary.withValues(
                      alpha: contentOpacity,
                    ),
                  ),
                ),
              ),

              PollActionMenu(
                poll: poll,
                isAuthor: true,
                iconOpacity: contentOpacity,
                onDelete: () {
                  context.read<MyPollsBloc>().add(DeletePollFromList(poll.id));
                },
                onClose: () {
                  context.read<MyPollsBloc>().add(
                    TogglePollStatusFromList(
                      pollId: poll.id,
                      currentStatus: poll.isClosed,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
