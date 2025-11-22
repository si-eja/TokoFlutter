import 'package:flutter/material.dart';
import '../api.service.dart';

class ProductEdit extends StatefulWidget {
  final Map<String, dynamic> editData;

  const ProductEdit({super.key, required this.editData});

  @override
  State<ProductEdit> createState() => _ProductEditState();
}

class _ProductEditState extends State<ProductEdit> {
  final ApiService api = ApiService();

  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController hargaCtrl = TextEditingController();
  final TextEditingController stokCtrl = TextEditingController();
  final TextEditingController deskripsiCtrl = TextEditingController();

  bool loading = false;
  List categories = [];
  int? selectedKategori;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() async {
    namaCtrl.text = widget.editData["nama_produk"] ?? "";
    hargaCtrl.text = widget.editData["harga"]?.toString() ?? "";
    stokCtrl.text = widget.editData["stok"]?.toString() ?? "";
    deskripsiCtrl.text = widget.editData["deskripsi"] ?? "";

    selectedKategori = int.tryParse(widget.editData["id_kategori"].toString());

    categories = await api.getCategories();
    setState(() {});
  }

  Future<void> saveEdit() async {
    if (selectedKategori == null ||
        namaCtrl.text.isEmpty ||
        hargaCtrl.text.isEmpty ||
        stokCtrl.text.isEmpty ||
        deskripsiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    setState(() => loading = true);

    final res = await api.saveProduct(
      idProduk: widget.editData["id_produk"],
      idKategori: selectedKategori!,
      namaProduk: namaCtrl.text,
      harga: int.tryParse(hargaCtrl.text) ?? 0,
      stok: int.tryParse(stokCtrl.text) ?? 0,
      deskripsi: deskripsiCtrl.text,
    );

    setState(() => loading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Produk berhasil diperbarui")));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"] ?? "Gagal menyimpan perubahan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black87),
        title: const Text(
          "Edit Produk",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : categories.isEmpty
              ? Center(child: Text("Memuat kategori..."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Kategori"),
                      const SizedBox(height: 6),

                      _dropdownKategori(),

                      const SizedBox(height: 20),

                      _label("Nama Produk"),
                      _input(namaCtrl),

                      const SizedBox(height: 20),

                      _label("Harga"),
                      _input(hargaCtrl, number: true),

                      const SizedBox(height: 20),

                      _label("Stok"),
                      _input(stokCtrl, number: true),

                      const SizedBox(height: 20),

                      _label("Deskripsi"),
                      _input(deskripsiCtrl, maxLines: 5),

                      const SizedBox(height: 30),

                      _buttonSimpan(),
                    ],
                  ),
                ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _dropdownKategori() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedKategori,
          items: categories.map<DropdownMenuItem<int>>((cat) {
            return DropdownMenuItem(
              value: cat["id_kategori"],
              child: Text(cat["nama_kategori"]),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedKategori = v),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c,
      {bool number = false, int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blueAccent, width: 1.3),
        ),
      ),
    );
  }

  Widget _buttonSimpan() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: saveEdit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          "Simpan Perubahan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}