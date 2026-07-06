import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/admin_data_store.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_background.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../home/main_screen.dart';

// 1. Convert LoginScreen to StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = const AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(AppLocalizations.of(context).translate('pleaseEnterEmailAndPassword'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.login(email: email, password: password);
      
      if (!mounted) return;
      
      final user = await _authService.getCurrentUser();
      
      if (!mounted) return;
      
      if (context.mounted) {
        context.read<AdminDataStore>().currentUser = user;
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AppBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),

            // 🔹 Logo
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              errorBuilder: (_, error, stackTrace) => Icon(
                Icons.visibility,
                size: 72,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 App Name — was missing!
            const Text(
              "LUXORA",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                loc.translate('welcome'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Email — fixed: added fill + border to match password field
            _buildField(
              hint: loc.translate('emailAddress'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),

const SizedBox(height: 20),

// 4. Password field with working toggle
_buildField(
  hint: loc.translate('password'),
  controller: _passwordController,
  obscure: _obscurePassword,
  suffix: IconButton(
    icon: Icon(
      _obscurePassword ? Icons.visibility_off : Icons.visibility,
      color: Colors.grey,
    ),
    onPressed: () {
      setState(() {
        _obscurePassword = !_obscurePassword;
      });
    },
  ),
),

            const SizedBox(height: 10),

            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  loc.translate('forgotPassword'),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Login Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        loc.translate('login'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Register Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(loc.translate('notAMember')),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    loc.translate('registerNow'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 3. Update _buildField to accept an onTap for the icon
  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        obscureText: obscure,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.light 
              ? Colors.black 
              : Colors.white,
          fontFamilyFallback: const ['Arial', 'sans-serif'],
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: suffix,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}