import 'package:flutter/material.dart';
import '../home/spin_home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../2_fridge_ai/fridge_ai_view.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const SpinHomeScreen(),
    const FavoritesScreen(),
    const FridgeAIView(),
    const ProfileScreen(),
    const AdminScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Tủ Lạnh AI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Quản lý',
          ),
        ],
      ),
    );
  }
}
