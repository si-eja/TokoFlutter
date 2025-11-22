import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api.service.dart';
import 'package:image_picker/image_picker.dart';

ValueNotifier<int?> selectedCat = ValueNotifier(null);

class ProductCreate extends StatefulWidget {
  const ProductCreate({super.key});

  @override
  State<ProductCreate> createState() => _ProductCreateState();
}

class _ProductCreateState extends State<ProductCreate> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  Widget _input(TextEditingController c,
    {bool number = false, int maxLines = 1}) {
      return TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? "Tidak boleh kosong" : null,
      );
    }
  // controllers
  int? selectedCategory;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  // image picker
  List<File> images = [];
  final ImagePicker picker = ImagePicker();

  bool isSaving = false;
  bool loadingCategories = true;

  List<dynamic> categories = [];
  int? kategori;

  // LOAD Category Dari API
  void loadCategories() async {
    final data = await api.getCategories();
    setState(() {
      categories = data;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }
  // === PILIH GAMBAR ===
  Future pickImages() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => images.add(File(picked.path)));
    }
  }

  // === SIMPAN PRODUK ===
  void doSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih kategori terlebih dahulu")));
      return;
    }

    setState(() => isSaving = true);
    
    final res = await api.saveProduct(
      idKategori: kategori!,
      namaProduk: nameCtrl.text.trim(),
      harga: int.tryParse(priceCtrl.text.trim()) ?? 0,
      stok: int.tryParse(stockCtrl.text.trim()) ?? 0,
      deskripsi: descCtrl.text.trim(),
    );

    if (res["success"] == true) {
      final idProduk = res['data']?['id_produk'] ??
          res['data']?['id'] ??
          res['id_produk'];

      if (idProduk != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil ditambah")));

        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal simpan produk")),
      );
    }

    setState(() => isSaving = false);
  }

  // === WIDGET INPUT ===
  Widget buildInput(String label, TextEditingController ctrl,
      {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),

        // box input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Masukkan $label",
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
            validator: (v) =>
                v == null || v.isEmpty ? "Masukkan $label" : null,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Produk"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),

      // === GRADIENT CYBER ===
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tambah Produk",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text("Kategori",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<int>(
                    value: kategori,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: categories.map<DropdownMenuItem<int>>((cat) {
                      return DropdownMenuItem(
                        value: cat["id_kategori"],
                        child: Text(cat["nama_kategori"]),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => kategori = v),
                    validator: (v) =>
                        v == null ? "Pilih kategori" : null,
                  ),

                  const SizedBox(height: 20),

                  // Input
                  Text("Nama Produk",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _input(nameCtrl),

                  const SizedBox(height: 12),

                  Text("Harga",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _input(priceCtrl, number: true),

                  const SizedBox(height: 12),

                  Text("Stok",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _input(stockCtrl, number: true),

                  const SizedBox(height: 12),

                  Text("Deskripsi",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  _input(descCtrl, maxLines: 5),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSaving ? null : doSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Simpan Produk",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
