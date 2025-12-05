import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'HELP',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Help Placeholder',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
