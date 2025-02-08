import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'home.dart';
import 'pelanggan.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://clbeillxmhzqxepnjdwh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNsYmVpbGx4bWh6cXhlcG5qZHdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTQwMjQsImV4cCI6MjA1NDI5MDAyNH0.A7ArFBEseUXfw7_nCjbTZLjEm_pqZKOom3E5Kq1ZpEw',
  );
  runApp(MyApp());
}
        
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      home: Login(), // Panggil halaman login
    );
  }
}
