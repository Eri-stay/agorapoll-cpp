import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/screens/home_screen.dart'; // A placeholder screen

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/images/parthenon_sketch.png',
                  width: MediaQuery.of(context).size.width * 0.75,
                ),
              ),
              const SizedBox(height: 48),
              const AuthTextField(
                label: 'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),
              const AuthTextField(
                label: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'LOG IN',
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
                    "Don't have an account? ",
                    style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
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
