import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _visible = true;
      });

      _routeAfterSplash();
    });
  }

  Future<void> _routeAfterSplash() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1800)),
      FirebaseAuth.instance.authStateChanges().first,
    ]);

    if (!mounted || _navigated) {
      return;
    }

    _navigated = true;
    final nextScreen = FirebaseAuth.instance.currentUser != null
      ? const HomeScreen()
      : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final iconSize = (screenSize.shortestSide * 0.80).clamp(400.0, 800.0);

    return Scaffold(
      backgroundColor: const Color(0xFF25180F),
      body: Center(
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 1000),
          child: Image.asset(
            'assets/Travixy Logo 1.png',
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
