import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  static void showAddProductDialog(BuildContext context, _ProdukState produkState) {
    final TextEditingController namaController = TextEditingController();
    final TextEditingController hargaController = TextEditingController();
    final TextEditingController stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                ),
                TextField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stokController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
            foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
            foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final String namaProduk = namaController.text.trim();
                final double? harga = double.tryParse(hargaController.text.trim());
                final int? stok = int.tryParse(stokController.text.trim());

                if (namaProduk.isNotEmpty && harga != null && stok != null) {
                  await produkState._addProduk(namaProduk, harga, stok);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Harap isi semua field dengan benar.'),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<ProdukPage> {
  List<dynamic> _produkList = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchProduk();
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

  Future<void> _addProduk(String namaProduk, double harga, int stok) async {
    try {
      final response = await Supabase.instance.client.from('produk').insert({
        'nama_produk': namaProduk,
        'harga': harga,
        'stok': stok,
      }).select();

      setState(() {
        _produkList.add(response[0]);
      });
    } catch (error) {
      debugPrint('Error adding produk: $error');
    }
  }

  Future<void> _editProduk(int produkId, String namaProduk, double harga, int stok) async {
    await Supabase.instance.client.from('produk').update({
      'nama_produk': namaProduk,
      'harga': harga,
      'stok': stok,
    }).eq('produk_id', produkId);
    _fetchProduk();
  }

  Future<void> _deleteProduk(int produkId) async {
    await Supabase.instance.client.from('produk').delete().eq('produk_id', produkId);
    _fetchProduk();
  }

  List<dynamic> get _filteredProdukList {
    return _produkList
        .where((produk) =>
            produk['nama_produk']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showEditProdukDialog(Map<String, dynamic> item) {
    final TextEditingController namaProdukController =
        TextEditingController(text: item['nama_produk']);
    final TextEditingController hargaController =
        TextEditingController(text: item['harga'].toString());
    final TextEditingController stokController =
        TextEditingController(text: item['stok'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaProdukController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                ),
                TextField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stokController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
            foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(148, 50, 119, 223),
            foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final String namaproduk = namaProdukController.text;
                final double harga = double.tryParse(hargaController.text) ?? 0.0;
                final int stok = int.tryParse(stokController.text) ?? 0;

                if (namaproduk.isNotEmpty && harga > 0 && stok >= 0) {
                  await _editProduk(item['produk_id'], namaproduk, harga, stok);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mohon isi data dengan benar.')),
                  );
                }
              },
              child: const Text('Simpan'),
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
          'Daftar Produk',
          style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          ),
        ),
      ),
    ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white60,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredProdukList.isEmpty
                ? const Center(child: Text('Produk tidak ditemukan.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProdukList.length,
                    itemBuilder: (context, index) {
                      final produk = _filteredProdukList[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(produk['nama_produk'],
                          style: const TextStyle(fontWeight: FontWeight.bold),),
                          subtitle: Text(
                            'Harga: ${produk['harga']} - Stok: ${produk['stok']}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF40A9FF)),
                                onPressed: () => _showEditProdukDialog(produk),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduk(produk['produk_id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ProdukPage.showAddProductDialog(context, this),
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 50, 119, 223),
        foregroundColor: Colors.black,
      ),
    );
  }
}