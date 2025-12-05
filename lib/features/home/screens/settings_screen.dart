import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'SETTINGS',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Settings Placeholder',
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
