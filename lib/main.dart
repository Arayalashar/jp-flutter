import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distribusi Jakhi',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginScreen(), // Memanggil layar login yang baru kita buat
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" di pojok
    );
  }
}