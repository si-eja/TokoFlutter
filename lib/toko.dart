import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toko_ku/aToko.dart';
import 'package:toko_ku/eToko.dart';
import '../api.service.dart';

class TokoPage extends StatefulWidget {
  const TokoPage({super.key});

  @override
  State<TokoPage> createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPage> {
  final ApiService api = ApiService();
  bool loading = true;
  List stores = [];

  @override
  
  void initState() {
    super.initState();
    loadStores();
  }
  void loadStores() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getString("store_data");

    if (local != null) {
      stores = [jsonDecode(local)];
      setState(() => loading = false);
      return; // ✅ tampilkan tanpa API
    }

    // ✅ kalau tidak ada lokal, coba API
    final data = await api.getStores();

    setState(() {
      stores = data;
      loading = false;
    });
  }
  void deleteStore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("store_data");

    setState(() {
      stores = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Toko berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Toko")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StoreCreatePage()),
          );
          if (res == true) loadStores();
        },
        child: Icon(Icons.store),
      ),
      body: loading
    ? Center(child: CircularProgressIndicator())
    : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (c, i) {
          final t = stores[i];

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // ICON TOKO
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.storefront,
                        size: 32, color: Colors.blueAccent),
                  ),

                  SizedBox(width: 14),

                  // INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t["nama_toko"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          t["deskripsi"] ?? "-",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),

                        SizedBox(height: 6),

                        Row(
                          children: [
                            Icon(Icons.phone,
                                size: 16, color: Colors.blueAccent),
                            SizedBox(width: 4),
                            Text(t["kontak"]),
                          ],
                        ),

                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.redAccent),
                            SizedBox(width: 4),
                            Expanded(
                                child: Text(
                              t["alamat"],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ACTION BUTTONS
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StoreEditPage(store: t),
                            ),
                          );

                          if (res == true) loadStores();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Hapus Toko"),
                              content: Text("Yakin ingin menghapus toko ini?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: Text("Batal"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    deleteStore();
                                  },
                                  child: Text("Hapus"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                )
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
