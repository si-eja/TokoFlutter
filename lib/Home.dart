import 'package:flutter/material.dart';

// Placeholder class untuk setiap halaman
class BerandaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Halaman Beranda', style: TextStyle(fontSize: 24)));
  }
}

class ProdukPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Halaman Produk', style: TextStyle(fontSize: 24)));
  }
}

class CariPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Halaman Cari', style: TextStyle(fontSize: 24)));
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Halaman Profile', style: TextStyle(fontSize: 24)));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Index halaman yang dipilih

  // List halaman untuk switch
  final List<Widget> _pages = [
    BerandaPage(),
    ProdukPage(),
    CariPage(),
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
      body: _pages[_selectedIndex], // Tampilkan halaman berdasarkan index
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
            icon: Icon(Icons.search),
            label: 'Cari',
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
        type: BottomNavigationBarType.fixed, // Fixed untuk 5 item
      ),
    );
  }
}