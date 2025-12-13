import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final AuthRepository _authRepository = AuthRepository();

  void _showColorPicker(Color currentColor) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick your color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('SAVE'),
            onPressed: () async {
              try {
                await _authRepository.updateUserData({
                  'avatarColor': pickerColor.toARGB32(),
                });
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating color: $e')),
                  );
                }
              }
              if (mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // Logout handler
  Future<void> _handleLogout() async {
    try {
      await _authRepository.signOut();
      if (mounted) {
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
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }
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
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            );
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          final userData = snapshot.data!.data()!;
          final Color avatarColor = userData['avatarColor'] != null
              ? Color(userData['avatarColor'])
              : const Color(0xFF8DAAAA);
          final String displayName =
              userData['displayName'] ??
              currentUser?.displayName ??
              'Anonymous User';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  _ProfileSection(
                    user: currentUser,
                    avatarColor: avatarColor,
                    displayName: displayName,
                    onColorChange: () => _showColorPicker(avatarColor),
                  ),
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
                  TextButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textPrimary,
                    ),
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
          );
        },
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
class _ProfileSection extends StatefulWidget {
  final User? user;
  final Color avatarColor;
  final String displayName;
  final VoidCallback onColorChange;

  const _ProfileSection({
    this.user,
    required this.avatarColor,
    required this.displayName,
    required this.onColorChange,
  });

  @override
  State<_ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<_ProfileSection> {
  late final TextEditingController _nameController;
  final AuthRepository _authRepository = AuthRepository();
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.displayName);
  }

  @override
  void didUpdateWidget(covariant _ProfileSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayName != oldWidget.displayName &&
        !_nameController.value.composing.isValid) {
      _nameController.text = widget.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name cannot be empty"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_nameController.text.trim() == widget.displayName) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSavingName = true);
    try {
      await _authRepository.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Name updated successfully!"),
            backgroundColor: AppColors.snackBarGrey,
          ),
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
        setState(() => _isSavingName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initial = widget.displayName.isNotEmpty
        ? widget.displayName[0].toUpperCase()
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
            GestureDetector(
              onTap: widget.onColorChange,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: widget.avatarColor,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.brush,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Click to change your colour',
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
          controller: _nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            suffixIcon: _isSavingName
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.save_outlined,
                      color: AppColors.accentGold,
                    ),
                    onPressed: _updateName,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Email",
          style: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          widget.user?.email ?? 'no-email@provided.com',
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
class _SecurityContent extends StatefulWidget {
  @override
  State<_SecurityContent> createState() => _SecurityContentState();
}

class _SecurityContentState extends State<_SecurityContent> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      setState(() => _isChangingPassword = true);
      try {
        await _authRepository.updateUserPassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password changed successfully!"),
              backgroundColor: AppColors.snackBarGrey,
            ),
          );
          _formKey.currentState?.reset();
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
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
          setState(() => _isChangingPassword = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CHANGE PASSWORD",
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text("Current Password"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Cannot be empty' : null,
          ),
          const SizedBox(height: 16),
          const Text("New Password"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Cannot be empty';
              if (value.length < 6) return 'Must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text("Confirm New Password"),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Cannot be empty';
              if (value != _newPasswordController.text)
                return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: _isChangingPassword ? 'SAVING...' : 'CHANGE PASSWORD',
            onPressed: _isChangingPassword ? () {} : _changePassword,
          ),
        ],
      ),
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
