import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/settings_switch.dart';
import '../../auth/repository/auth_repository.dart';
import '../../auth/screens/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final AuthRepository _authRepository = AuthRepository();

  // Logout handler
  Future<void> _handleLogout() async {
    try {
      await _authRepository.signOut();
      if (mounted) {
        // Return to the welcome screen, removing all navigation history
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            fontFamily: 'Cinzel',
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _ProfileSection(user: currentUser),
              const Divider(height: 32),
              _SettingsSection(
                title: 'NOTIFICATIONS',
                icon: Icons.notifications_none,
                content: _NotificationsContent(),
              ),
              const Divider(height: 32),
              _SettingsSection(
                title: 'SECURITY',
                icon: Icons.shield_outlined,
                content: _SecurityContent(),
              ),
              const Divider(height: 32),
              _SettingsSection(
                title: 'ABOUT',
                icon: Icons.info_outline,
                content: _AboutContent(),
              ),
              const SizedBox(height: 32),

              // --- LOG OUT BUTTON ---
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                label: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- DELETE ACCOUNT BUTTON ---
              PrimaryButton(
                text: 'DELETE ACCOUNT',
                color: AppColors.mutedDestructive,
                onPressed: () {
                  showConfirmationDialog(
                    context: context,
                    title: 'ARE YOU ABSOLUTELY SURE?',
                    content:
                        'This action cannot be undone. This will permanently delete your account and remove all your data from our servers, including all polls you\'ve created.',
                    confirmText: 'Delete Account',
                    onConfirm: () {
                      print(
                        "Account deletion confirmed by user (Placeholder).",
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Collapsible Section Widget ---
class _SettingsSection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget content;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  State<_SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<_SettingsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(widget.icon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: widget.content,
          ),
      ],
    );
  }
}

// --- Profile Section Widget ---
class _ProfileSection extends StatelessWidget {
  final User? user;
  const _ProfileSection({this.user});

  @override
  Widget build(BuildContext context) {
    final String initial = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : 'U';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PROFILE",
          style: TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF8DAAAA),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const Text(
              'Click to change your avatar',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          "Name",
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: user?.displayName ?? 'Anonymous User',
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Email",
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          user?.email ?? 'no-email@provided.com',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// --- Content for Notifications Section ---
class _NotificationsContent extends StatefulWidget {
  @override
  _NotificationsContentState createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<_NotificationsContent> {
  bool _email = true;
  bool _push = false;
  bool _reminders = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsSwitch(
          title: "Email Notifications",
          subtitle: "Receive poll updates via email",
          value: _email,
          onChanged: (v) => setState(() => _email = v),
        ),
        SettingsSwitch(
          title: "Push Notifications",
          subtitle: "Receive push notifications",
          value: _push,
          onChanged: (v) => setState(() => _push = v),
        ),
        SettingsSwitch(
          title: "Poll Closing Reminders",
          subtitle: "Get notified before your polls close",
          value: _reminders,
          onChanged: (v) => setState(() => _reminders = v),
        ),
      ],
    );
  }
}

// --- Content for Security Section ---
class _SecurityContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CHANGE PASSWORD",
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        const Text("Current Password"),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),
        const Text("New Password"),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),
        const Text("Confirm New Password"),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(text: 'CHANGE PASSWORD', onPressed: () {}),
      ],
    );
  }
}

// --- Content for About Section ---
class _AboutContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAboutTile("Version", "0.1.0"),
        const Divider(),
        _buildAboutTile("Legal", "Terms of Service & Privacy Policy"),
        const Divider(),
        _buildAboutTile("Support", "Help & Feedback"),
      ],
    );
  }

  Widget _buildAboutTile(String title, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontFamily: 'Inter')),
      trailing: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.textSecondary,
        ),
      ),
      onTap: () {},
    );
  }
}
