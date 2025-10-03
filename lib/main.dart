// lib/main.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DarijaPay Live',
      theme: AppTheme.themeData,
      home: Scaffold( // Temporary placeholder screen
        body: Center(
          child: Text('Setup Complete!', style: TextStyle(color: AppTheme.textHeadings)),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}