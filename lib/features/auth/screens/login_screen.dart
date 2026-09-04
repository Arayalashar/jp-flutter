import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../shared/screens/dashboard_screen.dart';
import '../../../shared/theme/light_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _usernameFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      CustomSnackbar.show(context, "Username dan password tidak boleh kosong.",
          isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.login(username, password);

    if (mounted) {
      if (result['success'] == true) {
        final user = result['user'];
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DashboardScreen(
                    role: user.role,
                    nama: user.namaLengkap,
                    idUser: user.idUser),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        CustomSnackbar.show(context, result['message'], isError: true);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: LightTheme.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ─────────────────────────────────
                  _buildLogo()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOutBack),

                  const SizedBox(height: 20),

                  // ── App Name ──────────────────────────────
                  Column(
                    children: [
                      Text(
                        'PT JAKHI PASARIBAWA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: LightTheme.textSecondary,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Logistik Navagreen',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: LightTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 600.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),

                  // ── Login Card ───────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: LightTheme.cardDecoration(radius: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 22,
                              decoration: BoxDecoration(
                                color: LightTheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: LightTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            'Masuk untuk mengakses sistem',
                            style: TextStyle(
                              fontSize: 13,
                              color: LightTheme.textSecondary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Username field
                        _buildTextField(
                          controller: _usernameController,
                          hint: 'Username',
                          icon: Icons.person_outline_rounded,
                          isFocused: _usernameFocused,
                          onFocusChange: (v) =>
                              setState(() => _usernameFocused = v),
                        ),
                        const SizedBox(height: 14),

                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isFocused: _passwordFocused,
                          onFocusChange: (v) =>
                              setState(() => _passwordFocused = v),
                        ),
                        const SizedBox(height: 28),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LightTheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'Masuk Sekarang',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.15, end: 0),

                  const SizedBox(height: 36),

                  Text(
                    '© 2026 PT Jakhi Pasaribawa',
                    style: TextStyle(
                      fontSize: 11,
                      color: LightTheme.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightTheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: LightTheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        width: 52,
        height: 52,
        color: Colors.white,
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isFocused = false,
    required ValueChanged<bool> onFocusChange,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: LightTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFocused ? LightTheme.primary : LightTheme.border,
            width: isFocused ? 1.5 : 1,
          ),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: TextStyle(
            color: LightTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: LightTheme.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: LightTheme.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused
                  ? LightTheme.primary
                  : LightTheme.textSecondary,
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: LightTheme.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
