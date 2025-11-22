import 'package:flutter/material.dart';
import 'package:toko_ku/ProdukD.dart';
import '../api.service.dart';

class HomeProdPage extends StatefulWidget {
  const HomeProdPage({super.key});

  @override
  State<HomeProdPage> createState() => _HomePageState();
}

class _HomePageState extends State<HomeProdPage> {
  final ApiService api = ApiService();
  bool loading = true;
  List products = [];
  List<Map<String, dynamic>> categories = [];
  TextEditingController searchCtrl = TextEditingController();
  List productsFiltered = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
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
  
  void loadCategories() async {
    final data = await api.getCategories();
    setState(() {
      categories = data.cast<Map<String, dynamic>>();
    });
  }
  String getCategoryName(dynamic idKategori) {
    if (categories.isEmpty) return "";

    final found = categories.where((c) {
      return c["id_kategori"].toString() == idKategori.toString();
    });

    if (found.isNotEmpty) {
      return found.first["nama_kategori"];
    }

    return "Tidak ada";
  }


  void loadProducts() async {
    final data = await api.getProducts();
    setState(() {
      products = data;
      productsFiltered = data; // <--- ini yang bikin produk tampil
      loadCategories();
      loading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: Container(
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
      child: Column(
        children: [
          // 🔍 SEARCH BOX
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              onChanged: searchProducts,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                hintText: "Cari produk...",
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white30),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),

          // GRID PRODUK
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: productsFiltered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, i) {
                final p = productsFiltered[i];
                final img = p["images"] ?? [];
                final imgUrl = img.isNotEmpty ? img[0]["url"] : null;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetail(productId: p["id_produk"]),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GAMBAR PRODUK
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          child: imgUrl != null
                              ? Image.network(
                                  imgUrl,
                                  width: double.infinity,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 120,
                                  color: Colors.white12,
                                  child: Icon(Icons.image,
                                      color: Colors.white70, size: 40),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // NAMA PRODUK (MAX 2 BARIS)
                              Text(
                                p["nama_produk"],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.2,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),

                              // HARGA (TEBAL)
                              Text(
                                "Rp ${p["harga"]}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreenAccent,
                                ),
                              ),
                              SizedBox(height: 6,),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  getCategoryName(p["id_kategori"]),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
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