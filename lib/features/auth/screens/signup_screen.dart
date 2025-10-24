import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/screens/home_screen.dart'; // A placeholder screen

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/images/parthenon_sketch.png',
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const AuthTextField(
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              const AuthTextField( // You added a "Name" field in the design
                label: 'Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              const AuthTextField(
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'CREATE ACCOUNT',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}