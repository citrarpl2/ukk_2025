import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'pelanggan.dart';
import 'produk.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Color.fromARGB(255, 74, 96, 219), // Sesuaikan dengan warna tombol di halaman login
        title: const Text(
          'Administrator Database',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
              color: Colors.white), // Mengubah warna teks menjadi putih
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                          (route) => false,
                        );
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? const ProdukPage() : _selectedIndex == 1
          ? const PelangganPage() : _selectedIndex == 2 
          ? PelangganPage() : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Color.fromARGB(255, 74, 96, 219),
        onTap: _onItemTapped,
        selectedItemColor: Colors.white54,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Pelanggan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Transaksi',
          ),
          
        ],
      ),
    );
  }
}