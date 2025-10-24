import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isPassword;

  const AuthTextField({
    Key? key,
    required this.icon,
    required this.label,
    this.isPassword = false,
  }) : super(key: key);

  @override
  _AuthTextFieldState createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: widget.isPassword ? _isObscured : false,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            hintText: 'Enter your ${widget.label.toLowerCase()}',
            prefixIcon: Icon(widget.icon, color: AppColors.textSecondary),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            )
                : null,
            filled: true,
            fillColor: AppColors.textFieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}