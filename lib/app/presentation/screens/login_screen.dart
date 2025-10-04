// lib/app/presentation/screens/login_screen.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/presentation/screens/signup_screen.dart';
import 'package:darijapay_live/app/presentation/widgets/custom_text_field.dart';
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthService _authService = widget.authService;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIN LOGIC ---
  void _login() async {
    setState(() => _isLoading = true);
    final result = await _authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // Handle login failure
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
        ),
      );
    }
    // The AuthGate will handle navigation on success.
    // We just need to stop the loading indicator.
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'DarijaPay Live',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textHeadings,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Share expenses, not headaches.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textBody, fontSize: 16),
                ),
                const SizedBox(height: 30),

                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 26),

                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _login, // Call the login function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            color: AppTheme.textHeadings,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SignUpScreen(authService: _authService),
                    ),
                  ),
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: AppTheme.textBody),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
