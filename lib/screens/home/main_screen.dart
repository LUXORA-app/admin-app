import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_localizations.dart';
import 'dashboard_screen.dart';
import '../../core/admin_data_store.dart';
import 'landmarks_admin_screen.dart';
import 'settings_screen.dart';
import 'users_admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch backend data once after login if user is admin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<AdminDataStore>().isCurrentUserAdmin) {
        context.read<AdminDataStore>().refreshAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final isAdmin = context.watch<AdminDataStore>().isCurrentUserAdmin;

    if (!isAdmin) {
      return const Scaffold(
        body: SettingsScreen(),
      );
    }

    List<Widget> pages = [
      DashboardScreen(
        onEditUsers: () => setState(() => currentIndex = 1),
        onEditLandmarks: () => setState(() => currentIndex = 2),
      ),
      const UsersAdminScreen(),
      const LandmarksAdminScreen(),
      const SettingsScreen(),
    ];

    final navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.dashboard_outlined),
        activeIcon: const Icon(Icons.dashboard),
        label: loc.translate('dashboard'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.people_outline),
        activeIcon: const Icon(Icons.people),
        label: loc.translate('users'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.place_outlined),
        activeIcon: const Icon(Icons.place),
        label: loc.translate('landmarks'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings_outlined),
        activeIcon: const Icon(Icons.settings),
        label: loc.translate('settings'),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        items: navItems,
      ),
    );
  }
}
