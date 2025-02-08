import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrasiPage extends StatefulWidget {
  @override
  _RegistrasiState createState() => _RegistrasiState();
}

class _RegistrasiState extends State<RegistrasiPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Tetap menggunakan nama fungsi _fetchRegistrasi
  Future<void> _fetchRegistrasi(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan password tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Periksa apakah username sudah terdaftar
      final response = await supabase
          .from('user')
          .select()
          .eq('username', username)
          .maybeSingle();

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username sudah terdaftar, coba username lain')),
        );
        return;
      }

      // Menyimpan password dengan hash (contoh: Anda bisa menggunakan library hashing seperti bcrypt)
      final hashedPassword = password; // Gantilah dengan hashed password jika diperlukan

      final insertResponse = await supabase.from('user').insert({
        'username': username,
        'password': password,
      }).select();

      print('Insert response: $insertResponse');

      if (insertResponse.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya setelah sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi gagal, coba lagi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: const Text('Registrasi Pengguna'),
        backgroundColor: const Color.fromARGB(255, 50, 119, 223),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();
                      _fetchRegistrasi(username, password); // Panggil _fetchRegistrasi di sini
                    },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Registrasi'),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 50, 119, 223),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
