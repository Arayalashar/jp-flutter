import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../../shared/theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _barController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _barWidth;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // Text animation
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Loading bar
    _barController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _barWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _textController.forward();
      _barController.forward();
    });

    Timer(const Duration(seconds: 3), _checkFirstSeen);
  }

  Future<void> _checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('onboarding_seen') ?? false);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              seen ? const LoginScreen() : const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF064E3B), // Emerald 900
              Color(0xFF065F46), // Emerald 800
              Color(0xFF047857), // Emerald 700
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Animated Logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Animated Text
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    Text(
                      "PT JAKHI PASARIBAWA",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Logistik\nNavagreen",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Loading bar
            AnimatedBuilder(
              animation: _barController,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 3,
                      child: LinearProgressIndicator(
                        value: _barWidth.value,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            Text(
              "© 2026 PT Jakhi Pasaribawa",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
