import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'shared/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/spv/providers/spv_provider.dart';
import 'features/gudang/providers/gudang_provider.dart';
import 'features/admin/providers/admin_provider.dart';
import 'features/supir/providers/supir_provider.dart';

import 'features/auth/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SpvProvider()),
        ChangeNotifierProvider(create: (_) => GudangProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
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
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}