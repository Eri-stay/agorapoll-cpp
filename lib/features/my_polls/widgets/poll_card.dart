import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/poll_model.dart';
import '../../poll_details/screens/poll_details_screen.dart';
import '../../shared/widgets/poll_action_menu.dart';

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

              // // Меню "три крапки"
              // PopupMenuButton<String>(
              //   onSelected: (value) {
              //     print('Selected: $value for poll: ${poll.question}');
              //   },
              //   icon: Icon(
              //     Icons.more_vert,
              //     color: AppColors.textSecondary.withValues(
              //       alpha: contentOpacity,
              //     ),
              //   ),

              //   color: AppColors.background,
              //   elevation: 4.0,

              //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              //     const PopupMenuItem<String>(
              //       value: 'close',
              //       child: Text('Close Poll'),
              //     ),
              //     const PopupMenuItem<String>(
              //       value: 'delete',
              //       child: Text(
              //         'Delete',
              //         style: TextStyle(color: AppColors.redText),
              //       ),
              //     ),
              //   ],
              // ),
              PollActionMenu(
                poll: poll,
                isAuthor: true,
                iconOpacity: contentOpacity,
                onDelete: () {
                  // TO DO: Додати подію в MyPollsBloc для видалення
                  print("Deleting poll from list: ${poll.id}");
                },
                onClose: () {
                  // TO DO: Додати подію в MyPollsBloc для закриття
                  print("Closing poll from list: ${poll.id}");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
