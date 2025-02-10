import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'produk.dart';
import 'pelanggan.dart';
import 'user.dart';
import 'transaksi.dart';
import 'riwayat.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        backgroundColor:Color.fromARGB(255, 50, 119, 223),
        title: const Text(
          'Prasmanan Bekti',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,
            color: Colors.white,),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(148, 50, 119, 223),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(148, 50, 119, 223),
                        foregroundColor: Colors.black,
                      ),
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
          ? UserPage()
          : _selectedIndex == 1
              ? ProdukPage()
              : _selectedIndex == 2
                  ? PelangganPage()
                  : _selectedIndex == 3
                      ? TransaksiPage()
                      : _selectedIndex == 4
                          ? RiwayatPage()
                          : Container(), 
                          

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          
              selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black54,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_add),
                      label: 'Registrasi',
                    ),
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
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history),
                      label: 'Riwayat',
                    ),
                  ],
                ),
              );
            }
          }
