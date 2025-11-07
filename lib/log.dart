import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toko_ku/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final String text = "TokoSK";
  List<bool> _visibleLetters = []; // List untuk track visibility setiap huruf

  @override
  void initState() {
    super.initState();

    // Inisialisasi semua huruf sebagai tidak terlihat
    _visibleLetters = List.generate(text.length, (index) => false);

    // Animasi muncul huruf satu per satu dengan delay 0.5 detik per huruf
    for (int i = 0; i < text.length; i++) {
      Timer(Duration(milliseconds: 500 * i), () {
        setState(() {
          _visibleLetters[i] = true; // Munculkan huruf ke-i
        });
      });
    }

    // Delay total 4 detik (sesuai panjang teks + buffer), lalu navigasi
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()), // Ganti dengan halaman utama Anda
      );
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueAccent.shade700], // Hitam gradasi ke biru neon
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(text.length, (index) {
              return AnimatedOpacity(
                opacity: _visibleLetters[index] ? 1.0 : 0.0, // Fade in/out berdasarkan visibility
                duration: Duration(milliseconds: 300), // Durasi fade per huruf
                child: Text(
                  text[index],
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Warna biru neon
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.blue, // Glow putih untuk efek neon
                        offset: Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 20.0,
                        color: Colors.black, // Glow biru tambahan
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}