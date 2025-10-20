// signup.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  // NOTE: This example does not store accounts persistently.
  // It just demonstrates a signup UI and returns to login screen.
  void _createAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text;

      // In a real app you'd call backend / store securely.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created for $name (local only)')),
      );

      // Optionally prefill the login screen by returning email
      Future.delayed(const Duration(milliseconds: 700), () {
        Navigator.pop(context); // go back to login
        // If you want to pass the created email to login screen, use Navigator.pushReplacement with args.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              'lib/images/1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.45)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width > 500 ? 460 : double.infinity,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Fill details to sign up', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 18),

                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter email';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) return 'Enter valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _passCtrl,
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
                              if (v == null || v.isEmpty) return 'Enter password';
                              if (v.length < 3) return 'Password must be 3+ chars';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _createAccount,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Sign up', style: TextStyle(fontSize: 16)),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Login'),
                              ),
                            ],
                          ),
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
