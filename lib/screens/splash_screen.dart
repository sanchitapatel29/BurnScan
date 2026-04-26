import 'dart:async';

import 'package:burn_scan/providers/auth_provider.dart';
import 'package:burn_scan/screens/home_screen.dart';
import 'package:burn_scan/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _logoScale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.55, curve: Curves.easeOut),
      ),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1, curve: Curves.easeOut),
      ),
    );

    unawaited(_prepareNavigation());
  }

  Future<void> _prepareNavigation() async {
    final authProvider = context.read<AuthProvider>();
    while (!authProvider.isReady) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      if (!mounted) {
        return;
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted || _navigated) {
      return;
    }

    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) =>
            authProvider.isLoggedIn ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF031E2A), Color(0xFF0A5C70), Color(0xFF45A3A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                height: 220,
                width: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x2200E1FF),
                ),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -40,
              child: Container(
                height: 240,
                width: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x22FF8A00),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 230,
                            width: 230,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(38),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.16),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 28,
                                  offset: Offset(0, 16),
                                ),
                              ],
                            ),
                            child: _AnimatedLogo(controller: _controller),
                          ),
                          const SizedBox(height: 28),
                          FadeTransition(
                            opacity: _textFade,
                            child: Column(
                              children: [
                                const Text(
                                  'BurnScan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Assess. Detect. Refine. Report.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.86),
                                    fontSize: 16,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: 170,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: const LinearProgressIndicator(
                                      minHeight: 6,
                                      backgroundColor: Color(0x33FFFFFF),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFFB43B),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final shimmer = Tween<double>(begin: -1.1, end: 1.3).transform(
          Curves.easeInOut.transform(controller.value.clamp(0, 1)),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _FallbackLogo(progress: controller.value);
                },
              ),
            ),
            IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Align(
                  alignment: Alignment(shimmer, 0),
                  child: Container(
                    width: 54,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0x55FFFFFF),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pulse = 1 + (0.04 * (1 - (progress - 0.7).abs()).clamp(0, 1));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3D8), Color(0xFFFFE1C0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Transform.scale(
          scale: pulse,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 126,
                color: Colors.deepOrange.shade700,
              ),
              const Icon(
                Icons.local_fire_department,
                size: 68,
                color: Color(0xFFFF6A00),
              ),
              const Positioned(
                right: 44,
                bottom: 54,
                child: Icon(
                  Icons.search,
                  size: 54,
                  color: Color(0xFF1679D6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
