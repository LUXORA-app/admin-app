import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/auth_storage.dart';
import '../../core/admin_data_store.dart';
import '../../widgets/app_background.dart';
import '../../core/app_colors.dart';
import '../../core/app_localizations.dart';
import '../auth/login_screen.dart';
import '../home/main_screen.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _goNext);
  }

  Future<void> _goNext() async {
    final token = await AuthStorage.getToken();
    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    try {
      final authService = const AuthService();
      final user = await authService.getCurrentUser();
      
      if (!mounted) return;
      
      context.read<AdminDataStore>().currentUser = user;
      
      if (user['role']?.toString() == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await AuthStorage.clearToken();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              errorBuilder: (_, error, stackTrace) => Icon(
                Icons.visibility,
                size: 88,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'LUXORA',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.translate('splashTagline'),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.translate('adminPanel'),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary.withValues(alpha: 0.85),
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
