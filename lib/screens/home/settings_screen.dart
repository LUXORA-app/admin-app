import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_background.dart';
import '../../core/app_colors.dart';
import '../../core/app_localizations.dart';
import '../../core/api_config.dart';
import '../auth/login_screen.dart';
import '../profile/profile_screen.dart';
import 'languages_screen.dart';

import '../../core/theme_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = const AuthService();
  Map<String, dynamic>? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final u = await _auth.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = u;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _auth.logout();
    } catch (_) {
      // Always proceed with local logout.
    }
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).translate('loggedOut'))),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final loc = AppLocalizations.of(context);

    final name = _user?['name']?.toString() ?? '';
    final email = _user?['email']?.toString() ?? '';
    final role = _user?['role']?.toString();
    final avatarUrl = ApiConfig.mediaUrl(_user?['avatar_url']?.toString());

    return AppBackground(
      overlayColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.6),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              loc.translate('settings'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 30),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (!_loading)
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary,
                child: avatarUrl != null && avatarUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
              ),
            const SizedBox(height: 10),
            if (!_loading) ...[
              Text(
                name.isNotEmpty ? name : loc.translate('emDash'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                email.isNotEmpty ? email : '',
                style: const TextStyle(color: Colors.grey),
              ),
              if (role != null && role.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role == 'admin' ? loc.translate('administrator') : role,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 40),
            _item(
              Icons.language,
              loc.translate('language'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguagesScreen(),
                  ),
                );
              },
            ),
            _item(
              Icons.person_outline,
              loc.translate('profile'),
              onTap: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                if (mounted) _loadUser();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.dark_mode_outlined,
                color: AppColors.primary,
              ),
              title: Text(loc.translate('appearance')),
              trailing: Switch(
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
            ),
            _item(
              Icons.logout,
              loc.translate('logout'),
              onTap: () => _logout(context),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _item(
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
