import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  State<ProdukPage> createState() => _ProdukState();
}

class _ProdukState extends State<ProdukPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelanggan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(
                      alignment: Alignment(0.1, 0.0),
                      child: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {},
                        color: Color(0xff212435),
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          Expanded(
            flex: 1,
            child: ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              shrinkWrap: false,
              physics: ScrollPhysics(),
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}
