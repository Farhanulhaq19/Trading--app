// main.dart
import 'package:flutter/material.dart';
import 'login.dart';
import 'Signup_screen.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const TradyApp());
}
// update
class TradyApp extends StatefulWidget {
  const TradyApp({super.key});

  @override
  State<TradyApp> createState() => _TradyAppState();
}
//class
class _TradyAppState extends State<TradyApp> {
  bool _isDark = false;

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trady App',
      debugShowCheckedModeBanner: false,
      theme: _isDark ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => DashboardScreen(onThemeToggle: _toggleTheme),
      },
    );
  }
}
