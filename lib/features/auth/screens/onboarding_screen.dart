import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/light_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: LightTheme.background,
        body: Stack(
          children: [
            // ── Top Hero Image Section ────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: size.height * 0.55,
                child: ClipPath(
                  clipper: const _WaveClipper(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo
                      Image.asset(
                        'assets/images/truck_2d.jpg',
                        fit: BoxFit.cover,
                      ),
                      // Dark + strong orange tint overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xCC1A0A00), // very dark orange-black
                              Color(0xAAFF7A00), // semi-transparent orange
                              Color(0x66FF9A3C), // lighter orange at bottom
                            ],
                            stops: [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Decorative orange circles
                      Positioned(
                        top: -20,
                        right: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LightTheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        left: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Logo badge
                      Positioned(
                        top: 56,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF9A3C),
                                      Color(0xFFFF7A00),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: LightTheme.primary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 28,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 44,
                                  height: 44,
                                  color: Colors.white,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 700.ms).scale(
                              begin: const Offset(0.6, 0.6),
                              curve: Curves.easeOutBack,
                            ),
                      ),
                      // Bottom text over image
                      Positioned(
                        bottom: 70,
                        left: 28,
                        right: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'PT JAKHI PASARIBAWA',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                letterSpacing: 3.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Logistik Navagreen',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms),
            ),

            // ── Bottom Content ────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                ),
                child: Column(
                  children: [
                    // Orange divider pill
                    const SizedBox(height: 20),
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A3C), Color(0xFFFF7A00)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main text
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: LightTheme.textPrimary,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                                children: [
                                  const TextSpan(text: 'Kelola Logistik\ndengan '),
                                  TextSpan(
                                    text: 'Mudah & Cepat',
                                    style: TextStyle(
                                      color: LightTheme.primary,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 600.ms)
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 12),
                            Text(
                              'Pantau pengiriman, kelola dokumen, dan\ntingkatkan efisiensi operasional.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: LightTheme.textSecondary,
                                height: 1.6,
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 500.ms, duration: 600.ms),
                            const SizedBox(height: 16),

                            // Feature pills — orange
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _FeaturePill(
                                    icon: Icons.local_shipping_rounded,
                                    label: 'Pengiriman'),
                                const SizedBox(width: 8),
                                _FeaturePill(
                                    icon: Icons.track_changes_rounded,
                                    label: 'Tracking'),
                                const SizedBox(width: 8),
                                _FeaturePill(
                                    icon: Icons.bar_chart_rounded,
                                    label: 'Laporan'),
                              ],
                            )
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 600.ms),
                          ],
                        ),
                      ),
                    ),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                      child: Column(
                        children: [
                          // CTA — gradient orange
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9A3C),
                                    Color(0xFFFF7A00),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: LightTheme.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _completeOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Mulai Sekarang',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  color: LightTheme.textSecondary,
                                ),
                                children: [
                                  const TextSpan(text: 'Sudah punya akun? '),
                                  TextSpan(
                                    text: 'Masuk',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: LightTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 700.ms, duration: 600.ms)
                          .slideY(begin: 0.1, end: 0),
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

// ── Feature Pill ───────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: LightTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: LightTheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: LightTheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: LightTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Wave Clip ──────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
