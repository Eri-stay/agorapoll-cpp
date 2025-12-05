import 'package:agora_poll/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CreatePollScreen extends StatelessWidget {
  const CreatePollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'CREATE A POLL',
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                PrimaryButton(
                  text: 'Test Crash!!!',
                  color: const Color(0xFFB75D69),
                  onPressed: () {
                    FirebaseCrashlytics.instance.crash();
                  },
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}
