import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'Login.dart';
import 'Signup_screen.dart';
void main() {
  runApp(const TradyApp());
}

class TradyApp extends StatefulWidget {
  const TradyApp({Key? key}) : super(key: key);

  @override
  State<TradyApp> createState() => _TradyAppState();
}

class _TradyAppState extends State<TradyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trady App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: DashboardScreen(onThemeToggle: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}
