import 'package:flutter/material.dart';
import '../api.service.dart';

class ProductDetail extends StatefulWidget {
  final int productId;
  final bool isMyProduct;

  const ProductDetail({super.key, required this.productId, this.isMyProduct = false});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final ApiService api = ApiService();
  Map? product;
  List images = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  void loadDetail() async {
    final detail = await api.getProductDetail(widget.productId);
    final imgs = await api.getProductImages(widget.productId);

    setState(() {
      product = detail;
      images = imgs;
      loading = false;
    });
  }

  void deleteProduct() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: ()=> Navigator.pop(context, true), child: const Text("Hapus")),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await api.deleteProduct(widget.productId);
    if (res["success"] == true) {
      Navigator.pop(context, true);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (product == null) return const Center(child: Text("Produk tidak ditemukan"));

    return Scaffold(
      backgroundColor: Colors.white, // biar cocok dengan gradient
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(product!["nama_produk"]),
      ),
      body: Container(
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
          padding: const EdgeInsets.all(20),
          children: [
            // --- GAMBAR UTAMA ---
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.10),
              ),
              child: images.isEmpty
                  ? Center(
                      child: Icon(Icons.image, size: 80, color: Colors.white70),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        images[0]["url"],
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            // --- NAMA PRODUK ---
            Text(
              product!["nama_produk"],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            // --- HARGA ---
            Text(
              "Rp ${product!["harga"]}",
              style: TextStyle(
                fontSize: 22,
                color: Colors.greenAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // --- CARD INFORMASI ---
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Stok: ${product!["stok"]}",
                      style: TextStyle(color: Colors.white, fontSize: 16)),

                  SizedBox(height: 8),

                  Text("Kategori: ${product!["nama_kategori"] ?? "-"}",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // --- DESKRIPSI ---
            Text(
              "Deskripsi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product!["deskripsi"] ?? "-",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}