import 'package:burn_scan/providers/auth_provider.dart';
import 'package:burn_scan/screens/home_screen.dart';
import 'package:burn_scan/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignup = false;
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006A6B), Color(0xFF54A5A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: InfoCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Burn Assessment',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Secure local access for offline clinical workflows.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().length < 3) {
                              return 'Enter at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Enter at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        if (authProvider.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            authProvider.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            child: Text(_isSignup ? 'Create Account' : 'Login'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _submitting
                                ? null
                                : () => setState(() => _isSignup = !_isSignup),
                            child: Text(
                              _isSignup
                                  ? 'Already have an account? Login'
                                  : 'Need an account? Sign up',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final authProvider = context.read<AuthProvider>();
    final success = _isSignup
        ? await authProvider.signup(
            _usernameController.text,
            _passwordController.text,
          )
        : await authProvider.login(
            _usernameController.text,
            _passwordController.text,
          );

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        ),
      );
    }
  }
}
