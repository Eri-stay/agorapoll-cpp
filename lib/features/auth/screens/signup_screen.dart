import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/screens/home_screen.dart';
import '../repository/auth_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthRepository _authRepository = AuthRepository();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authRepository.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );

        await FirebaseAnalytics.instance.logSignUp(
          signUpMethod: 'email_password',
        );

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

                    AuthTextField(
                      controller: _emailController, // -> Pass the controller
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email cannot be empty';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null; // -> Return null if the value is valid.
                      },
                    ),
                    const SizedBox(height: 24),

                    AuthTextField(
                      controller: _nameController,
                      label: 'Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      text: _isLoading ? 'CREATING...' : 'CREATE ACCOUNT',
                      onPressed: _isLoading ? () {} : _createAccount,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
