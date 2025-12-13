import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onHelpTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;
  final String? displayName;
  final String? email;
  final Color avatarColor;

  const SideMenu({
    super.key,
    required this.onHelpTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
    this.displayName,
    this.email,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    // Extract first letter for avatar
    final String initial = (displayName != null && displayName!.isNotEmpty)
        ? displayName![0].toUpperCase()
        : 'U';

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Avatar Section
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: 'Cinzel',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/images/wreath.svg',
                        width: 87, // Ширина всього віджету
                        height: 76, // Висота всього віджету
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    displayName ?? 'User',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    email ?? '',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Divider(color: Colors.grey[300], height: 1),
            const SizedBox(height: 20),

            _buildMenuItem(
              icon: Icons.help_outline,
              text: 'Help & Support',
              onTap: onHelpTap,
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              text: 'Settings',
              onTap: onSettingsTap,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildMenuItem(
                icon: Icons.logout,
                text: 'Log Out',
                onTap: onLogoutTap,
                isDestructive: true,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red[400] : AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: isDestructive ? Colors.red[400] : AppColors.textPrimary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
