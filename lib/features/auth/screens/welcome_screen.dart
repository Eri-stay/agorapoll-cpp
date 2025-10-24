import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // We will create this next
import '../../../core/theme/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/parthenon_sketch.png',
                width: MediaQuery.of(context).size.width * 0.85,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              width: MediaQuery.of(context).size.width * 0.85,
              alignment: Alignment.center,
              child: const Text(
                'AGORAPOLL',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 40,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ask. Vote. Decide.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}