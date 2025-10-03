// lib/app/presentation/screens/auth_gate.dart
import 'package:darijapay_live/app/presentation/screens/dashboard_screen.dart'; // Will create soon
import 'package:darijapay_live/app/presentation/screens/login_screen.dart';   // Will create soon
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // User is not logged in or data not available yet
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }
        // User is logged in
        return const DashboardScreen();
      },
    );
  }
}