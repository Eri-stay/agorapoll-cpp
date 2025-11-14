import 'package:flutter/material.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
