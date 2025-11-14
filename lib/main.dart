import 'package:flutter/material.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  //FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await FirebaseAnalytics.instance.logBeginCheckout();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgoraPoll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mutedGold),
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
}
