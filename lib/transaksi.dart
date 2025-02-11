import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransaksiPage extends StatefulWidget {
  @override
  _TransaksiState createState() => _TransaksiState();
}

class _TransaksiState extends State<TransaksiPage> {
  List<dynamic> _produkList = [];
  List<dynamic> _pelangganList = [];
  Map<int, int> _keranjang = {}; // Menyimpan jumlah produk berdasarkan ID
  int? _pelangganId; // Bisa null awalnya, nanti diisi oleh dropdown


  @override
  void initState() {
    super.initState();
    _fetchProduk();
    _fetchPelangganId();
    _fetchPelangganList();
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

  Future<void> _fetchPelangganList() async {
  try {
    final response = await Supabase.instance.client
        .from('pelanggan')
        .select();  // Ambil seluruh data pelanggan

    setState(() {
      _pelangganList = response as List<dynamic>; // Menyimpan data pelanggan
    });
  } catch (error) {
    debugPrint('Error fetching pelanggan list: $error');
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

   Widget _buildPelangganDropdown() {
  if (_pelangganList.isEmpty) {
    return const CircularProgressIndicator(); // Menampilkan progress indicator jika data belum tersedia
  }

  return DropdownButton<int>(
    value: _pelangganId, // ID pelanggan yang dipilih
    hint: Text('Pilih Pelanggan'),
    isExpanded: true,
    items: _pelangganList.map((pelanggan) {
      return DropdownMenuItem<int>(
        value: pelanggan['pelanggan_id'],
        child: Text(pelanggan['nama_pelanggan']),
      );
    }).toList(),
    onChanged: (int? newValue) {
      setState(() {
        _pelangganId = newValue; // Set ID pelanggan yang dipilih
      });
    },
  );
}

  Future<void> _addTransaksi() async {
  if (_keranjang.isEmpty) return;
  
  try {
    final totalTransaksi = _hitungTotal();
    final pelangganId = _pelangganId; // Ambil ID pelanggan yang dipilih

    // Cari nama pelanggan berdasarkan id yang dipilih
    final pelanggan = _pelangganList.firstWhere(
      (p) => p['pelanggan_id'] == pelangganId,
      orElse: () => {} as Map<String, dynamic>, // Jika tidak ditemukan, kembalikan null
    );

    if (pelanggan.isEmpty) {
      debugPrint("Pelanggan tidak ditemukan!");
      return;
    }

    final namaPelanggan = pelanggan['nama_pelanggan'] ?? 'Tidak Diketahui'; // Ambil nama pelanggan

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
        orElse: () => Map<String, dynamic>.from({}), // Hindari error jika produk tidak ditemukan
      );

      if (produk == null) {
        debugPrint("Produk dengan ID ${entry.key} tidak ditemukan!");
        continue;
      }

      // **Pengecekan stok produk terlebih dahulu**
      if (produk['stok'] >= entry.value) {
        // Mengurangi stok produk setelah transaksi
        await Supabase.instance.client.from('produk').update({
          'stok': produk['stok'] - entry.value, // Kurangi stok produk sesuai jumlah yang dibeli
        }).eq('produk_id', produk['produk_id']);

      await Supabase.instance.client.from('detail_penjualan').insert({
        'penjualan_id': penjualanId,
        'produk_id': produk['produk_id'],
        'jumlah_produk': entry.value,
        'subtotal': produk['harga'] * entry.value,
      });

      // Tambahkan detail ke `detailStruk`
      detailStruk.add({
        'nama_produk': produk['nama_produk'],
        'harga': produk['harga'],
        'jumlah_produk': entry.value,
        'subtotal': produk['harga'] * entry.value,
      });
    } else {
        // Menampilkan pesan jika stok tidak cukup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stok tidak mencukupi!')),
        );
        debugPrint("Stok produk tidak mencukupi!");
        return;
      }
    }

    // Tampilkan struk setelah transaksi selesai
    _tampilkanStruk(detailStruk, totalTransaksi, namaPelanggan);

    setState(() {
      _keranjang.clear();
    });

    await _fetchProduk();

  } catch (error) {
    debugPrint('Error adding transaksi: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terjadi kesalahan, coba lagi.')),
    );
  }
}

  void _tampilkanStruk(List<Map<String, dynamic>> detailStruk, double total, String namaPelanggan) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Warung Makan Bekti',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nama Pelanggan: $namaPelanggan',
                style: const TextStyle(fontWeight: FontWeight.w200, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            ...detailStruk.map((item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: ListTile(
                  title: Text(item['nama_produk']),
                  subtitle: Text(
                      '${item['jumlah_produk']} x Rp ${item['harga']} = Rp ${item['subtotal']}'),
                ),
              );
            }).toList(),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Subtotal: Rp ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
              Navigator.of(context).pop(); // Menutup struk
              // Panggil konfirmasi transaksi hanya setelah menutup dialog
              _tampilkanKonfirmasiTransaksi(); 
            },
            child: const Text('Bayar'),
          ),
        ],
      );
    },
  );
}

void _tampilkanKonfirmasiTransaksi() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Transaksi Berhasil!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Terima kasih telah berbelanja di Warung Makan Bekti.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
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
              Navigator.of(context).pop(); // Menutup dialog konfirmasi transaksi
            },
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
             _buildPelangganDropdown(), // Dropdown untuk memilih pelanggan

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
                    'subtotal: Rp ${_hitungTotal().toStringAsFixed(2)}',
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