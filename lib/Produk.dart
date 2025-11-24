import 'package:flutter/material.dart';
import 'package:toko_ku/AProduk.dart';
import 'package:toko_ku/EProduk.dart';
import '../api.service.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final ApiService api = ApiService();
  bool loading = true;
  List products = [];
  List productsFiltered = [];
  TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void loadProducts() async {
    final data = await api.getProducts();
    setState(() {
      products = data;
      productsFiltered = data;
      loading = false;
    });
  }

  void searchProducts(String keyword) {
    if (keyword.isEmpty) {
      setState(() => productsFiltered = products);
      return;
    }

    final q = keyword.toLowerCase();
    setState(() {
      productsFiltered = products.where((p) {
        return p["nama_produk"].toString().toLowerCase().contains(q);
      }).toList();
    });
  }

  // 🔥 HAPUS PRODUK
  Future<void> deleteProduct(int idProduk) async {
    final res = await api.deleteProduct(idProduk);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produk berhasil dihapus")),
      );
      loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal menghapus produk")),
      );
    }
  }

  void confirmDelete(int idProduk) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Hapus Produk"),
          content: Text("Yakin ingin menghapus produk ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await deleteProduct(idProduk); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Hapus"),
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
        title: Text("Produk", style: TextStyle(color: Colors.blueAccent)),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductCreate()),
          );
          if (res == true) loadProducts();
        },
        child: Icon(Icons.add),
      ),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent.shade700, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // 🔍 SEARCH BOX
                  Container(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: searchProducts,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.15),
                        hintText: "Cari produk...",
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: productsFiltered.length,
                      itemBuilder: (context, i) {
                        final p = productsFiltered[i];
                        final img = p["images"] ?? [];
                        final imgUrl = img.isNotEmpty ? img[0]["url"] : null;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.20)),
                          ),

                          child: Row(
                            children: [
                              // FOTO
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imgUrl != null
                                    ? Image.network(imgUrl,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover)
                                    : Container(
                                        width: 55,
                                        height: 55,
                                        color: Colors.white12,
                                        child: Icon(Icons.image,
                                            color: Colors.white70),
                                      ),
                              ),

                              SizedBox(width: 14),

                              // NAMA + HARGA
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p["nama_produk"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Rp ${p["harga"]}",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),

                              // Edit
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductEdit(editData: p),
                                    ),
                                  ).then((value) {
                                    if (value == true) loadProducts();
                                  });
                                },
                              ),

                              // Hapus
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => confirmDelete(p["id_produk"]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}