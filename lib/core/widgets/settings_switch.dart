import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsSwitch extends StatelessWidget {
  final String title;
  final String? subtitle; // Може бути null (наприклад, для налаштувань профілю)
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    Key? key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2), // Невеликий відступ
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.accentGold,
              activeThumbColor: Colors.white,

              inactiveTrackColor: Colors.grey[200],
              inactiveThumbColor: AppColors.charcoal,
              // Outline color - transparent
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              trackOutlineWidth: WidgetStateProperty.all(0),
            ),
          ),
        ],
      ),
    );
  }
}
