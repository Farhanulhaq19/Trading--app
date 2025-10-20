// login.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController =
  TextEditingController(text: 'will@befarhan.com'); // prefill for convenience
  final TextEditingController _passwordController =
  TextEditingController(text: '123'); // prefill for convenience
  bool _obscure = true;

  // Hardcoded valid credentials (local-only)
  final String validEmail = 'will@befarhan.com';
  final String validPassword = '123';

  void _tryLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;

      if (email == validEmail && pass == validPassword) {
        // success
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'lib/images/1.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Dim overlay for readability
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // Form card
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: SizedBox(
                      width: size.width > 500 ? 420 : double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Welcome Back',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Login to continue', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Please enter email';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) return 'Enter valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Please enter password';
                              if (v.length < 3) return 'Password too short';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _tryLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Login', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: const Text('Sign up'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          const Text(
                            'Tip: test credential -> will@befarhan.com / 123',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
