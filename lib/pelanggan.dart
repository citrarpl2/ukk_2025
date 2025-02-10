import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({Key? key}) : super(key: key);

  @override
  State<PelangganPage> createState() => _PelangganState();
}

class _PelangganState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelanggan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
  }

  Future<void> _fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      setState(() {
        pelanggan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      _showError('Terjadi kesalahan saat mengambil data pelanggan: $e');
    }
  }

  Future<void> _addPelanggan(String nama, String alamat, String nomorTelepon) async {
    try {
      final response = await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          pelanggan.add(response.first);
        });
      }
    } catch (e) {
      _showError('Gagal menambahkan pelanggan: $e');
    }
  }

  Future<void> _editPelanggan(int id, String nama, String alamat, String nomorTelepon) async {
    try {
      final response = await supabase.from('pelanggan').update({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'nomor_telepon': nomorTelepon,
      }).eq('pelanggan_id', id).select();

      if (response != null && response.isNotEmpty) {
        setState(() {
          final index = pelanggan.indexWhere((item) => item['pelanggan_id'] == id);
          if (index != -1) {
            pelanggan[index] = response.first;
          }
        });
      }
    } catch (e) {
      _showError('Gagal mengedit pelanggan: $e');
    }
  }

  Future<void> _deletePelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
      setState(() {
        pelanggan.removeWhere((item) => item['pelanggan_id'] == id);
      });
    } catch (e) {
      _showError('Gagal menghapus pelanggan: $e');
    }
  }

  // Fungsi untuk menampilkan error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Fungsi untuk menampilkan dialog tambah/edit pelanggan
  void _showAddPelangganDialog({Map<String, dynamic>? pelangganData}) {
    final TextEditingController namaController = TextEditingController(
        text: pelangganData != null ? pelangganData['nama_pelanggan'] : '');
    final TextEditingController alamatController = TextEditingController(
        text: pelangganData != null ? pelangganData['alamat'] : '');
    final TextEditingController nomorTeleponController = TextEditingController(
        text: pelangganData != null ? pelangganData['nomor_telepon'] : '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pelangganData == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
              ),
              TextField(
                controller: nomorTeleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                keyboardType: TextInputType.phone,
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
                final String nama = namaController.text;
                final String alamat = alamatController.text;
                final String nomorTelepon = nomorTeleponController.text;

                if (nama.isNotEmpty && alamat.isNotEmpty && nomorTelepon.isNotEmpty) {
                  if (pelangganData == null) {
                    _addPelanggan(nama, alamat, nomorTelepon);
                  } else {
                    _editPelanggan(pelangganData['pelanggan_id'], nama, alamat, nomorTelepon);
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
          content: const Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
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
                await _deletePelanggan(id); // Hapus pelanggan jika dikonfirmasi
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
          'Data Pelanggan',
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
          : pelanggan.isEmpty
              ? const Center(child: Text('Tidak ada pelanggan!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pelanggan.length,
                  itemBuilder: (context, index) {
                    final item = pelanggan[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: ListTile(
                        title: Text(
                          item['nama_pelanggan'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat: ${item['alamat']}'),
                            Text('Nomor Telepon: ${item['nomor_telepon']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddPelangganDialog(pelangganData: item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(item['pelanggan_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPelangganDialog(),
        child: const Icon(Icons.add),
        backgroundColor:const Color.fromARGB(255, 50, 119, 223),
      ),
    );
  }
}