import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api.service.dart';

class StoreCreatePage extends StatefulWidget {
  const StoreCreatePage({super.key});

  @override
  State<StoreCreatePage> createState() => _StoreCreatePageState();
}

class _StoreCreatePageState extends State<StoreCreatePage> {
  final ApiService api = ApiService();

  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController deskCtrl = TextEditingController();
  final TextEditingController kontakCtrl = TextEditingController();
  final TextEditingController alamatCtrl = TextEditingController();

  bool loading = false;

  void saveStore() async {
    if (namaCtrl.text.isEmpty ||
        deskCtrl.text.isEmpty ||
        kontakCtrl.text.isEmpty ||
        alamatCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    setState(() => loading = true);

    final res = await api.saveStore(
      nama: namaCtrl.text,
      deskripsi: deskCtrl.text,
      kontak: kontakCtrl.text,
      alamat: alamatCtrl.text,
    );

    setState(() => loading = false);

    if (res["success"] == true || res["message"]?.contains("tidak memiliki izin") == true) {

      // ✅ SIMPAN DATA TOKO LOKAL DI SINI
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("store_data", jsonEncode({
        "nama_toko": namaCtrl.text,
        "deskripsi": deskCtrl.text,
        "kontak": kontakCtrl.text,
        "alamat": alamatCtrl.text,
      }));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Toko berhasil dibuat")),
      );

      Navigator.pop(context, true); // ✅ setelah simpan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal membuat toko")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buat Toko"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.shade700,
              Colors.black,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            TextField(
              controller: namaCtrl,
              decoration: inputStyle("Nama Toko"),
            ),
            SizedBox(height: 12),

            TextField(
              controller: deskCtrl,
              maxLines: 2,
              decoration: inputStyle("Deskripsi"),
            ),
            SizedBox(height: 12),

            TextField(
              controller: kontakCtrl,
              decoration: inputStyle("Kontak (WhatsApp)"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),

            TextField(
              controller: alamatCtrl,
              decoration: inputStyle("Alamat"),
              maxLines: 2,
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : saveStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Simpan Toko", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration inputStyle(String title) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.15),
      labelText: title,
      labelStyle: TextStyle(color: Colors.white70),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white30),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}