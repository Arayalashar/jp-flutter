import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  double _dragPosition = 0.0;
  bool _isFinished = false;

  Future<void> _completeOnboarding() async {
    if (_isFinished) return;
    _isFinished = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF064E3B),
              Color(0xFF065F46),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Top section — illustration area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.55,
              child: Image.asset(
                'assets/images/truck_2d.jpg',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.3),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // Gradient overlay
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xFF065F46),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Distribusi Lebih\nCerdas & Cepat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Kelola pengiriman barang, pantau status\nrealtime, dan tingkatkan efisiensi logistik.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Swipe button
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double buttonWidth = constraints.maxWidth;
                        double thumbSize = 64.0;
                        double maxDrag = buttonWidth - thumbSize;

                        return Container(
                          height: thumbSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(thumbSize / 2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Stack(
                            children: [
                              // Progress fill
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: _dragPosition + thumbSize,
                                height: thumbSize,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(thumbSize / 2),
                                ),
                              ),
                              // Text
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Geser untuk mulai  >>>",
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: (1 - (_dragPosition / maxDrag)).clamp(0.3, 1.0),
                                    ),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Thumb
                              Positioned(
                                left: _dragPosition,
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    setState(() {
                                      _dragPosition += details.delta.dx;
                                      if (_dragPosition < 0) _dragPosition = 0;
                                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                                    });
                                  },
                                  onHorizontalDragEnd: (details) {
                                    if (_dragPosition > maxDrag * 0.75) {
                                      setState(() => _dragPosition = maxDrag);
                                      _completeOnboarding();
                                    } else {
                                      setState(() => _dragPosition = 0);
                                    }
                                  },
                                  child: Container(
                                    width: thumbSize,
                                    height: thumbSize,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primary, Color(0xFF34D399)],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.4),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
