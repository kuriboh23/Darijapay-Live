// lib/app/presentation/screens/auth_gate.dart
import 'package:darijapay_live/app/presentation/screens/dashboard_screen.dart';
import 'package:darijapay_live/app/presentation/screens/login_screen.dart';
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:darijapay_live/app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Create single instances of services to be passed down
  static final AuthService _authService = AuthService();
  static final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // User is not logged in or data not available yet
        if (!snapshot.hasData || snapshot.data == null) {
          return LoginScreen(authService: _authService);
        }
        // User is logged in
        return DashboardScreen(
          authService: _authService,
          firestoreService: _firestoreService,
        );
      },
    );
  }
}
