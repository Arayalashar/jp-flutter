import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/spv/providers/spv_provider.dart';
import 'features/gudang/providers/gudang_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/admin/providers/notification_provider.dart';
import 'features/supir/providers/supir_provider.dart';

import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SpvProvider()),
        ChangeNotifierProvider(create: (_) => GudangProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SupirProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distribusi Jakhi',
      theme: AppTheme.darkGlassTheme,
      home: const _StartupRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Reads SharedPreferences then routes to Onboarding or Login
class _StartupRouter extends StatelessWidget {
  const _StartupRouter();

  Future<bool> _checkOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkOnboardingSeen(),
      builder: (context, snapshot) {
        // Still loading — show blank light screen (no splash)
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
          );
        }

        final onboardingSeen = snapshot.data!;
        return onboardingSeen ? const LoginScreen() : const OnboardingScreen();
      },
    );
  }
}