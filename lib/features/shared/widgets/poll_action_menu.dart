import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/poll_model.dart';
import '../../../core/widgets/confirmation_dialog.dart';

enum PollAction { toggleStatus, delete, report }

class PollActionMenu extends StatefulWidget {
  final Poll poll;
  final bool isAuthor; // will determine which options to show
  final double iconOpacity; // For transparency in PollCard

  // Callback functions to notify parent about actions
  final VoidCallback? onDelete;
  final VoidCallback? onClose;
  final VoidCallback? onReport;

  const PollActionMenu({
    Key? key,
    required this.poll,
    required this.isAuthor,
    this.iconOpacity = 1.0,
    this.onDelete,
    this.onClose,
    this.onReport,
  }) : super(key: key);

  @override
  State<PollActionMenu> createState() => _PollActionMenuState();
}

class _PollActionMenuState extends State<PollActionMenu> {
  // Method that handles selection
  void _handleSelection(PollAction action) {
    switch (action) {
      case PollAction.delete:
        showConfirmationDialog(
          context: context,
          title: 'DELETE POLL?',
          content:
              'Are you sure you want to delete this poll? This action cannot be undone. All votes and data associated with this poll will be permanently removed.',
          confirmText: 'Delete Poll',
          onConfirm: () {
            // only call the callback after confirmation
            widget.onDelete?.call();
          },
        );
        break;
      case PollAction.toggleStatus:
        widget.onClose?.call();
        break;
      case PollAction.report:
        widget.onReport?.call();
        break;
    }
  }

  // Method to build menu items based on user role
  List<PopupMenuEntry<PollAction>> _buildMenuItems(BuildContext context) {
    if (widget.isAuthor) {
      // Menu for the author
      return [
        PopupMenuItem<PollAction>(
          value: PollAction.toggleStatus,
          child: Text(widget.poll.isClosed ? 'Open Poll' : 'Close Poll'),
        ),
        const PopupMenuItem<PollAction>(
          value: PollAction.delete,
          child: Text('Delete', style: TextStyle(color: AppColors.redText)),
        ),
      ];
    } else {
      // Menu for the regular user
      return [
        const PopupMenuItem<PollAction>(
          value: PollAction.report,
          child: Text('Report Poll'),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PollAction>(
      onSelected: _handleSelection,
      icon: Icon(
        Icons.more_vert,
        color: AppColors.textSecondary.withValues(alpha: widget.iconOpacity),
      ),
      color: AppColors.background,
      elevation: 4.0,
      itemBuilder: _buildMenuItems,
    );
  }
}
