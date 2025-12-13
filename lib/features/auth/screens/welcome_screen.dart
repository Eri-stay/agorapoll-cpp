import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import '../../../core/theme/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Створюємо два ф'ючери: один для ініціалізації Firebase,
      // інший для мінімальної затримки у 2 секунди.
      final firebaseInitialization = Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final splashDelay = Future.delayed(const Duration(seconds: 2));

      // Чекаємо на завершення обох.
      // Навігація відбудеться тільки після того, як Firebase буде готовий
      // І пройде щонайменше 2 секунди.
      await Future.wait([firebaseInitialization, splashDelay]);

      // Перевіряємо, чи віджет все ще в дереві, перш ніж робити навігацію
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Якщо сталася помилка, оновлюємо стан, щоб показати повідомлення
      setState(() {
        _errorMessage =
            "Failed to connect to services. Please check your internet connection and try again.";
        print("Firebase initialization error: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/images/parthenon_sketch.png',
                  width: MediaQuery.of(context).size.width * 0.85,
                ),
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
            if (_errorMessage == null)
              const Text(
                'Ask. Vote. Decide.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
