import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreEditPage extends StatefulWidget {
  final Map store;
  const StoreEditPage({super.key, required this.store});

  @override
  State<StoreEditPage> createState() => _StoreEditPageState();
}

class _StoreEditPageState extends State<StoreEditPage> {
  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController deskCtrl = TextEditingController();
  final TextEditingController kontakCtrl = TextEditingController();
  final TextEditingController alamatCtrl = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    namaCtrl.text   = widget.store["nama_toko"];
    deskCtrl.text   = widget.store["deskripsi"];
    kontakCtrl.text = widget.store["kontak"];
    alamatCtrl.text = widget.store["alamat"];
  }

  void saveEdit() async {
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

    // ✅ SIMPAN KE LOCAL
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      "store_data",
      jsonEncode({
        "nama_toko": namaCtrl.text,
        "deskripsi": deskCtrl.text,
        "kontak": kontakCtrl.text,
        "alamat": alamatCtrl.text,
      }),
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Perubahan disimpan")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Toko"),
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
              onPressed: loading ? null : saveEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Simpan Perubahan",
                      style: TextStyle(color: Colors.white)),
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
