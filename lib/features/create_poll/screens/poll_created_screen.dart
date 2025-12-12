import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import 'create_poll_screen.dart';
import '../../poll_details/screens/poll_details_screen.dart';

// --- LOGIC WIDGET ---
class PollCreatedScreen extends StatelessWidget {
  final String pollCode;
  final String pollId;

  const PollCreatedScreen({
    Key? key,
    required this.pollCode,
    required this.pollId,
  }) : super(key: key);

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: pollCode));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Code copied to clipboard",
          style: TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),
        backgroundColor: AppColors.snackBarGrey,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToPoll(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PollDetailsScreen(pollId: pollId)),
    );
  }

  void _createAnother(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreatePollScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PollCreatedView(
      pollCode: pollCode,
      onCopyTap: () => _copyToClipboard(context),
      onViewPollTap: () => _navigateToPoll(context),
      onCreateAnotherTap: () => _createAnother(context),
    );
  }
}

// --- VIEW WIDGET ---
class _PollCreatedView extends StatelessWidget {
  final String pollCode;
  final VoidCallback onCopyTap;
  final VoidCallback onViewPollTap;
  final VoidCallback onCreateAnotherTap;

  const _PollCreatedView({
    Key? key,
    required this.pollCode,
    required this.onCopyTap,
    required this.onViewPollTap,
    required this.onCreateAnotherTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // wreath with check icon
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gold Circle
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Check Icon
                    const Icon(Icons.check, color: Colors.white, size: 40),
                    Positioned.fill(
                      // child: Image.asset(
                      //   'assets/images/hell-wreath.png',
                      //   fit: BoxFit.contain,
                      // ),
                      child: Opacity(
                        opacity: 1,
                        child: Image.asset(
                          'assets/images/hell-wreath-success.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Title and subtitle
              const Text(
                'POLL CREATED',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your poll has been created successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Code box
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGreyBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Share this code:',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onCopyTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pollCode,
                            style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.content_copy,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Buttons
              PrimaryButton(text: 'VIEW POLL', onPressed: onViewPollTap),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onCreateAnotherTap,
                child: const Text(
                  'CREATE ANOTHER POLL',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
