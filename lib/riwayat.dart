import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatPage extends StatefulWidget {

  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<RiwayatPage> {
  List<Map<String, dynamic>> _riwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    try {
      final response = await Supabase.instance.client
          .from('detail_penjualan')
          .select('detail_id, penjualan_id, produk_id, jumlah_produk, subtotal, produk(nama_produk)')
          .order('penjualan_id', ascending: false);
      setState(() {
        _riwayat = _groupByTransactionId(response);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching riwayat penjualan: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

   // Fungsi untuk mengelompokkan transaksi berdasarkan penjualan_id
  List<Map<String, dynamic>> _groupByTransactionId(List<dynamic> response) {
    Map<int, List<Map<String, dynamic>>> grouped = {};

    for (var item in response) {
      int penjualanId = item['penjualan_id'];
      if (!grouped.containsKey(penjualanId)) {
        grouped[penjualanId] = [];
      }
      grouped[penjualanId]!.add(item);
    }

    // Mengubah map menjadi list of maps untuk digunakan di ListView
    return grouped.entries.map((entry) {
      return {
        'penjualan_id': entry.key,
        'produk': entry.value.map((e) => e['produk']['nama_produk']).toList(),
        'jumlah_produk': entry.value.map((e) => e['jumlah_produk']).toList(),
        'subtotal': entry.value.map((e) => e['subtotal']).toList(),
      };
    }).toList();
  }

   Future<void> _deleteRiwayat(int detailId) async {
    try {
      await Supabase.instance.client
          .from('detail_penjualan')
          .delete()
          .eq('detail_id', detailId);
      setState(() {
        _riwayat.removeWhere((item) => item['detail_id'] == detailId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Riwayat transaksi berhasil dihapus!')),
      );
    } catch (error) {
      debugPrint('Error deleting riwayat: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan saat menghapus.')),
      );
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi penghapusan riwayat
  void _showDeleteConfirmationDialog(int detailId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus riwayat transaksi ini?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog jika batal
              },
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                await _deleteRiwayat(detailId); // Hapus jika dikonfirmasi
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
            'Riwayat Transaksi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _riwayat.isEmpty
              ? const Center(child: Text('Tidak ada riwayat penjualan.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _riwayat.length,
                  itemBuilder: (context, index) {
                    final item = _riwayat[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text('Penjualan ID: ${item['penjualan_id']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Produk: ${item['produk'].join(', ')}'),
                            Text(
                              'Jumlah: ${item['jumlah_produk'].join(', ')} | Subtotal: ${item['subtotal'].join(', ')}',
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Hapus riwayat berdasarkan detail_id produk
                            // Anda bisa menambahkan lebih logika untuk memilih detail_id yang tepat
                            _showDeleteConfirmationDialog(item['penjualan_id']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}