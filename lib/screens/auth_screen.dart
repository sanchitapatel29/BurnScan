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
  final _fullNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignup = false;
  bool _submitting = false;
  String? _selectedRole;

  static const _roles = [
    'Burn Specialist',
    'Emergency Physician',
    'Nurse',
    'Paramedic',
    'Resident Doctor',
    'Technician',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _hospitalController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF032C35), Color(0xFF0A7778), Color(0xFF58B5B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.14),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BurnScan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Offline-first burn assessment for clinical teams, built for fast imaging workflows and local reporting.',
                            style: TextStyle(
                              color: Color(0xFFD9F3F2),
                              height: 1.45,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    InfoCard(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F5F5),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_outlined,
                                    color: Color(0xFF0A7778),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isSignup
                                            ? 'Create local account'
                                            : 'Secure local access',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(fontSize: 26),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isSignup
                                            ? 'Capture first-time clinician details before creating the local account.'
                                            : 'Sign in to continue the burn assessment workflow.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (_isSignup) ...[
                              TextFormField(
                                controller: _fullNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icon(
                                    Icons.badge_outlined,
                                    color: Color(0xFF0A7778),
                                  ),
                                ),
                                validator: (value) {
                                  if (!_isSignup) {
                                    return null;
                                  }
                                  if (value == null ||
                                      value.trim().length < 3) {
                                    return 'Enter your full name.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                items: _roles
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _selectedRole = value);
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Clinical role',
                                  prefixIcon: Icon(
                                    Icons.local_hospital_outlined,
                                    color: Color(0xFF0A7778),
                                  ),
                                ),
                                validator: (value) {
                                  if (!_isSignup) {
                                    return null;
                                  }
                                  if (value == null || value.isEmpty) {
                                    return 'Select your clinical role.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _hospitalController,
                                decoration: const InputDecoration(
                                  labelText: 'Hospital / facility',
                                  hintText: 'Enter hospital or clinic name',
                                  prefixIcon: Icon(
                                    Icons.apartment_outlined,
                                    color: Color(0xFF0A7778),
                                  ),
                                ),
                                validator: (value) {
                                  if (!_isSignup) {
                                    return null;
                                  }
                                  if (value == null ||
                                      value.trim().length < 2) {
                                    return 'Enter your hospital or facility.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'Professional email',
                                  hintText: 'Enter your work email',
                                  prefixIcon: Icon(
                                    Icons.alternate_email,
                                    color: Color(0xFF0A7778),
                                  ),
                                ),
                                validator: (value) {
                                  if (!_isSignup) {
                                    return null;
                                  }
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty || !email.contains('@')) {
                                    return 'Enter a valid email.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Color(0xFF0A7778),
                                ),
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
                                hintText: 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF0A7778),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Enter at least 6 characters.';
                                }
                                return null;
                              },
                            ),
                            if (_isSignup) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm password',
                                  hintText: 'Re-enter your password',
                                  prefixIcon: Icon(
                                    Icons.verified_outlined,
                                    color: Color(0xFF0A7778),
                                  ),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (!_isSignup) {
                                    return null;
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            if (authProvider.error != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3F4),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFF1C9CE),
                                  ),
                                ),
                                child: Text(
                                  authProvider.error!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _submitting ? null : _submit,
                                icon: Icon(
                                  _isSignup
                                      ? Icons.person_add_alt_1_outlined
                                      : Icons.login_rounded,
                                ),
                                label: Text(
                                  _isSignup ? 'Create Account' : 'Login',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _submitting
                                    ? null
                                    : () => setState(() {
                                          _isSignup = !_isSignup;
                                          if (!_isSignup) {
                                            _fullNameController.clear();
                                            _hospitalController.clear();
                                            _emailController.clear();
                                            _confirmPasswordController.clear();
                                            _selectedRole = null;
                                          }
                                        }),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0A7778),
                                  minimumSize: const Size.fromHeight(56),
                                  side: const BorderSide(
                                    color: Color(0xFFA1D0D1),
                                    width: 1.3,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
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
                  ],
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
