import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../polls/screens/my_polls_screen.dart';
import '../../search/screens/search_screen.dart';
import '../widgets/side_menu_column.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyPollsScreen(),
    Text('Create Screen'), // Заглушка
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background, // Встановлюємо фон для всього екрана
      body: SafeArea(
        child: Stack(
          children: [
            // Шар 1: Основний контент (AppBar + Body + BottomNav)
            Column(
              children: [
                // Наш кастомний AppBar
                _buildAppBar(),
                // Розширюємо Body, щоб він займав увесь доступний простір
                Expanded(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
                // Наш кастомний BottomNavigationBar
                _buildBottomNavBar(),
              ],
            ),

            // Шар 2: Колона поверх усього
            if (_selectedIndex == 0 || _selectedIndex == 2)
              const SideMenuColumn(),
          ],
        ),
      ),
    );
  }

  // Виносимо AppBar в окремий метод для чистоти коду
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent, // Робимо фон прозорим
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

  // Виносимо BottomNav в окремий метод
  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(left: 30),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1.0)),
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'My Polls'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.accentGold,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.transparent, // Робимо фон прозорим
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0: return 'MY POLLS';
      case 1: return 'CREATE A POLL';
      case 2: return '';
      default: return 'AGORAPOLL';
    }
  }
}