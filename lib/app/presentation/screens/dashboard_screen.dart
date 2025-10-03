// lib/app/presentation/screens/dashboard_screen.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard', style: TextStyle(color: AppTheme.textHeadings)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textHeadings),
            onPressed: () => AuthService().signOut(), // Logout functionality
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome! You are logged in as ${AuthService().currentUser?.email ?? 'User'}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textBody, fontSize: 18),
        ),
      ),
    );
  }
}