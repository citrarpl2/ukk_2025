import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<TransaksiPage> {
  List<dynamic> _produkList = [];
  Map<int, int> _keranjang = {}; // Menyimpan jumlah produk berdasarkan ID
  int? _pelangganId; // Bisa null awalnya, nanti diisi oleh dropdown


  @override
  void initState() {
    super.initState();
    _fetchProduk();
    _fetchPelangganId();
  }

  Future<void> _fetchPelangganId() async {
  try {
    final response = await Supabase.instance.client
        .from('pelanggan')
        .select('pelanggan_id') // Ambil hanya ID pelanggan
        .limit(1) // Ambil hanya satu pelanggan (bisa diubah sesuai kebutuhan)
        .single(); // Pastikan hanya satu data yang diambil

    setState(() {
      _pelangganId = response['pelanggan_id']; // Simpan ID pelanggan
    });

  } catch (error) {
    debugPrint('Error fetching pelanggan_id: $error');
  }
}

  Future<void> _fetchProduk() async {
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        _produkList = response as List<dynamic>;
      });
    } catch (error) {
      debugPrint('Error fetching produk: $error');
    }
  }

  void _tambahKeKeranjang(int produkId) {
    setState(() {
      _keranjang[produkId] = (_keranjang[produkId] ?? 0) + 1;
    });
  }

  void _kurangDariKeranjang(int produkId) {
    setState(() {
      if (_keranjang.containsKey(produkId) && _keranjang[produkId]! > 0) {
        _keranjang[produkId] = _keranjang[produkId]! - 1;
        if (_keranjang[produkId] == 0) {
          _keranjang.remove(produkId);
        }
      }
    });
  }

  double _hitungTotal() {
    double total = 0.0;
    for (var produk in _produkList) {
      int jumlah = _keranjang[produk['produk_id']] ?? 0;
      total += jumlah * produk['harga'];
    }
    return total;
  }

Future<void> _addTransaksi() async {
  if (_keranjang.isEmpty) return;
  
  try {
    final totalTransaksi = _hitungTotal();
    final pelangganId = 1; // Gantilah dengan ID pelanggan yang benar

    // Tambahkan ini di awal sebelum loop
    List<Map<String, dynamic>> detailStruk = [];

    // Insert ke tabel penjualan
    final response = await Supabase.instance.client
        .from('penjualan')
        .insert({
          'tanggal_penjualan': DateTime.now().toIso8601String(),
          'total_harga': totalTransaksi,
          'pelanggan_id': pelangganId, // Pastikan ID pelanggan benar
        })
        .select('penjualan_id')
        .single();

    final penjualanId = response['penjualan_id']; // Ambil ID transaksi baru

    // Loop untuk memasukkan detail transaksi
    for (var entry in _keranjang.entries) {
      final produk = _produkList.firstWhere(
        (p) => p['produk_id'] == entry.key,
        orElse: () => null, // Hindari error jika produk tidak ditemukan
      );

      if (produk == null) {
        debugPrint("Produk dengan ID ${entry.key} tidak ditemukan!");
        continue;
      }

      await Supabase.instance.client.from('detail_penjualan').insert({
        'penjualan_id': penjualanId,
        'produk_id': produk['produk_id'],
        'quantity': entry.value,
        'total': produk['harga'] * entry.value,
      });

      // Tambahkan detail ke `detailStruk`
      detailStruk.add({
        'nama_produk': produk['nama_produk'],
        'harga': produk['harga'],
        'quantity': entry.value,
        'total': produk['harga'] * entry.value,
      });
    }

    // Tampilkan struk setelah transaksi selesai
    _tampilkanStruk(detailStruk, totalTransaksi);

    setState(() {
      _keranjang.clear();
    });

  } catch (error) {
    debugPrint('Error adding transaksi: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan, coba lagi.')),
    );
  }
}


  void _tampilkanStruk(List<Map<String, dynamic>> detailStruk, double total) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Struk Belanja'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...detailStruk.map((item) => ListTile(
                    title: Text(item['nama_produk']),
                    subtitle: Text(
                        '${item['quantity']} x Rp ${item['harga']} = Rp ${item['total']}'),
                  )),
              const Divider(),
              Text(
                'Total: Rp ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
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
            'Transaksi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _produkList.length,
                itemBuilder: (context, index) {
                  final produk = _produkList[index];
                  final jumlah = _keranjang[produk['produk_id']] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(produk['nama_produk'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Rp ${produk['harga']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () => _kurangDariKeranjang(produk['produk_id']),
                          ),
                          Text('$jumlah', style: const TextStyle(fontSize: 16.0)),
                          IconButton(
                            icon: const Icon(Icons.add, color: const Color.fromARGB(255, 50, 119, 223)),
                            onPressed: () => _tambahKeKeranjang(produk['produk_id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Rp ${_hitungTotal().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _keranjang.isEmpty ? null : _addTransaksi,
                    child: const Text('Selesaikan Transaksi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}