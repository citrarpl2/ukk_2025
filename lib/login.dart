import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false; // Tambahkan ini untuk mengontrol visibility password

  Future<void> _login() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showMessage("Username tidak boleh kosong");
      return;
    }
    else if (password.isEmpty) {
      _showMessage("Password tidak boleh kosong");
      return;
    }

    try {
      final response = await supabase
          .from('user')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response == null) {
        _showMessage("Username tidak ditemukan");
        return;
      }

      final String storedPassword = response['password'];

      if (storedPassword != password) {
        _showMessage("Password salah");
        return;
      }

      _showMessage("Login berhasil!");
        // Login berhasil, arahkan ke halaman Home
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()),
        );
    } catch (error) {
      _showMessage("Terjadi kesalahan: $error");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: Colors.black,
                radius: 60,
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 34, 89, 172),
                  size: 100,
                ),
              ),
              const SizedBox(height: 90),
              
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,  // Mengatur visibility password
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;  // Toggle password visibility
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 61, 118, 204),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                  fontFamily: 'Poppins', // Sesuaikan dengan font favoritmu
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}