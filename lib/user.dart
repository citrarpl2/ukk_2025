import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserState();
}

class _UserState extends State<UserPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> user = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final response = await supabase.from('user').select();
      setState(() {
        user = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      _showError('Terjadi kesalahan saat mengambil data petugas: $e');
    }
  }

  Future<void> _addUser(String username, String password) async {
    try {
      final response = await supabase.from('user').insert({
        'username': username,
        'password': password,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          user.add(response.first);
        });
      }
    } catch (e) {
      _showError('Gagal menambahkan petugas: $e');
    }
  }

  Future<void> _editUser(int id, String username, String password) async {
    try {
      final response = await supabase.from('user').update({
        'username': username,
        'password': password,
      }).eq('id', id).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          final index = user.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            user[index] = response.first;
          }
        });
      }
    } catch (e) {
      _showError('Gagal mengedit petugas: $e');
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      await supabase.from('user').delete().eq('id', id);
      setState(() {
        user.removeWhere((item) => item['id'] == id);
      });
    } catch (e) {
      _showError('Gagal menghapus petugas: $e');
    }
  }

  List<dynamic> get _filteredUser {
    return _filteredUser
        .where((produk) =>
            produk['nama_produk']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Fungsi untuk menampilkan error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Fungsi untuk menampilkan dialog tambah/edit pelanggan
  void _showAddUserDialog({Map<String, dynamic>? petugasData}) {
    final TextEditingController usernameController = TextEditingController(
        text: petugasData != null ? petugasData['username'] : '');
    final TextEditingController passwordController = TextEditingController(
        text: petugasData != null ? petugasData['password'] : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(petugasData == null ? 'Tambah Petugas' : 'Edit Petugas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final String username = usernameController.text;
                final String password = passwordController.text;

                if (username.isNotEmpty && password.isNotEmpty) {
                  if (petugasData == null) {
                    _addUser(username, password);
                  } else {
                    _editUser(petugasData['id'], username, password);
                  }
                  Navigator.of(context).pop();
                } else {
                  _showError('Mohon isi semua data dengan benar.');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi penghapusan
  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus petugas ini?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
            foregroundColor: Colors.black,
              ),
              onPressed: () async {
                await _deleteUser(id); // Hapus pelanggan jika dikonfirmasi
                Navigator.of(context).pop(); // Tutup dialog setelah penghapusan
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child:  Text(
            'Data Petugas',
              style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user.isEmpty
              ? const Center(child: Text('Tidak ada petugas!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    final item = user[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          item['username'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password: ${item['password']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddUserDialog(petugasData: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(item['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(),
        child: const Icon(Icons.add),
        backgroundColor:const Color.fromARGB(255, 50, 119, 223),
      ),
    );
  }
}