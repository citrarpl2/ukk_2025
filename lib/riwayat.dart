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
        _riwayat = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching riwayat penjualan: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child:  Text(
            'Riwayat Penjualan',
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
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _riwayat.length,
                  itemBuilder: (context, index) {
                    final item = _riwayat[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text('Produk: ${item['produk']['nama_produk']}'),
                        subtitle: Text(
                          'Jumlah: ${item['jumlah_produk']} | Subtotal: ${item['subtotal']}',
                        ),
                        trailing: Text(
                          'Penjualan ID: ${item['penjualan_id']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}