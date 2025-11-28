import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'login.dart';
import 'Signup_screen.dart';
import 'dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB89RzpBfCx34vZOqhmfXlkkzc_fjDN7W0",
      appId: "1:526747796464:android:2a3bca32a5c7fb1c11d335",
      messagingSenderId: "526747796464",
      projectId: "trading--app-167a4",
      storageBucket: "trading--app-167a4.firebasestorage.app",
    ),
  );

  runApp(const TradyApp());
}

class TradyApp extends StatefulWidget {
  const TradyApp({super.key});

  @override
  State<TradyApp> createState() => _TradyAppState();
}

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
        '/dashboard': (context) =>
            DashboardScreen(onThemeToggle: _toggleTheme),
      },
    );
  }
}
