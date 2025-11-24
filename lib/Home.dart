import 'package:flutter/material.dart';
import 'package:toko_ku/Home(api).dart';
import 'package:toko_ku/Produk.dart';
import 'package:toko_ku/Profile.dart';
import 'package:toko_ku/toko.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index halaman yang dipilih

  // List halaman untuk switch
  final List<Widget> _pages = [
    HomeProdPage(),
    ProdukPage(),
    TokoPage(),
    ProfilePage(),
  ];

  // Fungsi untuk ganti halaman
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ), // Tampilkan halaman berdasarkan index
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shop),
            label: 'Toko',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Index aktif
        selectedItemColor: Colors.blueAccent, // Warna item aktif
        unselectedItemColor: Colors.grey, // Warna item tidak aktif
        backgroundColor: Colors.black, // Background nav bar
        onTap: _onItemTapped, // Handler tap
        type: BottomNavigationBarType.fixed, // Fixed untuk 4 item
      ),
    );
  }
}