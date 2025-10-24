import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class MyPollsScreen extends StatelessWidget {
  const MyPollsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (polls.isEmpty) ... else ...
    return const EmptyPollsWidget();
  }
}

class EmptyPollsWidget extends StatelessWidget {
  const EmptyPollsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        //padding: const EdgeInsets.symmetric(horizontal: 40.0),
        padding: const EdgeInsets.only(left: 60, right: 40, bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/meander_circle.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Agora is empty. Create your first poll to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'CREATE A POLL',
              onPressed: () {
                print('Create a poll button tapped');
              },
            )
          ],
        ),
      ),
    );
  }
}