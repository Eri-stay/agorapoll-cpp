import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../my_polls/screens/my_polls_screen.dart';
import '../../search/screens/search_screen.dart';
import '../widgets/side_menu_column.dart';
import '../widgets/side_menu.dart';
import '../../create_poll/screens/create_poll_screen.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../auth/repository/auth_repository.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final AuthRepository _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _closeMenu() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

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
      // Handle error if needed
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    MyPollsScreen(),
    Text('Create Screen'), // Placeholder
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreatePollScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double columnTotalWidth = screenHeight * 0.132;
    final double hiddenWidth = columnTotalWidth * 0.4;
    final double _menuWidth = min(320, screenWidth - columnTotalWidth * 0.5);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const WelcomeScreen();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          // Слухаємо дані користувача з Firestore
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            // Визначаємо колір за замовчуванням
            Color avatarColor = const Color(0xFF8DAAAA); // Колір-заглушка
            String displayName = user.displayName ?? 'User';
            String email = user.email ?? '';

            if (snapshot.hasData && snapshot.data!.exists) {
              final userData = snapshot.data!.data()!;
              displayName = userData['displayName'] ?? displayName;
              email = userData['email'] ?? email;
              if (userData['avatarColor'] != null) {
                avatarColor = Color(userData['avatarColor']);
              }
            }

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                // Swipe right to open
                if (details.delta.dx > 0 && _animationController.isDismissed) {
                  if (details.globalPosition.dx < 100) {
                    // Start swipe from left area
                    _animationController.forward();
                  }
                }
                // Swipe left to close
                if (details.delta.dx < 0 && _animationController.isCompleted) {
                  _animationController.reverse();
                }
              },
              child: Stack(
                children: [
                  // Layer 1: Main Content
                  Column(
                    children: [
                      _buildAppBar(),
                      Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
                      _buildBottomNavBar(),
                    ],
                  ),

                  // Layer 2: Dark Overlay
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _animation.value > 0
                          ? Positioned.fill(
                              child: GestureDetector(
                                onTap: _closeMenu,
                                child: Container(
                                  color: Colors.black.withOpacity(
                                    _animation.value * 0.5,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),

                  // Layer 3: Side Menu Content
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final user = FirebaseAuth.instance.currentUser;
                      return Positioned(
                        left: -_menuWidth * (1 - _animation.value),
                        top: 0,
                        bottom: 0,
                        width: _menuWidth,
                        child: SideMenu(
                          displayName: displayName,
                          email: user?.email,
                          avatarColor: avatarColor,
                          onHelpTap: () {
                            _closeMenu();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpScreen(),
                              ),
                            );
                          },
                          onSettingsTap: () {
                            _closeMenu();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          onLogoutTap: _handleLogout,
                        ),
                      );
                    },
                  ),

                  // Layer 4: The Column (Handle)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final double startLeft = -hiddenWidth;
                      final double endLeft = _menuWidth - hiddenWidth;
                      final double currentLeft =
                          startLeft +
                          (_animation.value * (endLeft - startLeft));

                      return Positioned(
                        left: currentLeft,
                        top: 0,
                        bottom: 0,
                        child: SideMenuColumn(
                          isOpen: _animation.value > 0.5,
                          onToggle: _toggleMenu,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    if ([0, 1].contains(_selectedIndex)) {
      return Container(
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
          ),
        ),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            _getAppBarTitle(_selectedIndex),
            style: const TextStyle(
              fontFamily: 'Cinzel',
              color: AppColors.textPrimary,
              fontSize: 36,
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(left: 30),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'My Polls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'MY POLLS';
      case 1:
        return 'CREATE A POLL';
      case 2:
        return '';
      default:
        return 'AGORAPOLL';
    }
  }
}
