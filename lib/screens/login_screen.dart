import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart'; // Kita akan buat file ini setelah ini

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Untuk menampilkan loading saat proses login

  // Fungsi untuk mengirim data ke PHP (XAMPP)
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    // URL API PHP kita (karena pakai Chrome Web, localhost bisa digunakan)
    var url = Uri.parse('http://localhost/JP/login_api.php');

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      var data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        String role = data['data']['role'];
        String nama = data['data']['nama_lengkap'];
        String idUser = data['data']['id_user'].toString(); // MENGAMBIL ID USER

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // MENGIRIM ID USER KE DASHBOARD
            builder: (context) => DashboardScreen(role: role, nama: nama, idUser: idUser), 
          ),
        );
      } else {
        // Jika gagal, tampilkan pesan error dari PHP (misal: password salah)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Jika XAMPP mati atau error jaringan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: Tidak dapat terhubung ke server."), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "PT Jakhi Pasaribawa",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                "Sistem Logistik Distribusi\nNavagreen",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
              SizedBox(height: 40),

              Text("Username", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "Masukkan Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 20),

              Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Masukkan Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _login, // Tombol mati saat loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Masuk",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}