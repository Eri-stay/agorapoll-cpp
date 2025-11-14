import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../polls/screens/my_polls_screen.dart';
import '../../search/screens/search_screen.dart';
import '../widgets/side_menu_column.dart';
import '../../create_poll/screens/create_poll_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyPollsScreen(),
    Text('Create Screen'), // Заглушка not p;aceholder
    SearchScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreatePollScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
                // кастомний BottomNavigationBar
                _buildBottomNavBar(),
              ],
            ),

            // Column
            if (_selectedIndex == 0 || _selectedIndex == 2)
              const SideMenuColumn(),
          ],
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
