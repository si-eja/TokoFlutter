import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';


class ApiService {
  // Ganti dengan URL API kamu
  static const String baseUrl = "https://learncode.biz.id/api";

  // -----------------------------
  // Helper untuk ambil token
  // -----------------------------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // -----------------------------
  // LOGIN
  // -----------------------------
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(res.body);

      // Jika login sukses → simpan token
      if (res.statusCode == 200 && data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
      }

      return data;

    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e"
      };
    }
  }

  // -----------------------------
  // REGISTER
  // -----------------------------
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      return jsonDecode(res.body);

    } catch (e) {
      return {
        "success": false,
        "message": "Gagal terhubung ke server: $e"
      };
    }
  }

  // -----------------------------
  // GET USER (PAKAI TOKEN)
  // -----------------------------
  Future<Map<String, dynamic>> getUser() async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/profile");

    try {
      final res = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      return jsonDecode(res.body);

    } catch (e) {
      return {
        "success": false,
        "message": "Gagal memuat profil: $e"
      };
    }
  }

  // -----------------------------
  // LOGOUT
  // -----------------------------
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove("token");
  }
  // -----------------------------
  // GET ALL PRODUCTS
  // -----------------------------
  Future<List<dynamic>> getProducts() async {
    final url = Uri.parse("$baseUrl/products");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // API tampaknya merespon { "data": [ ... ] }
        return data["data"] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // -----------------------------
  // GET PRODUCT DETAIL
  // -----------------------------
  Future<Map<String, dynamic>?> getProductDetail(int idProduk) async {
    final url = Uri.parse("$baseUrl/products/$idProduk/show");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // -----------------------------
  // GET PRODUCT IMAGES (by product id)
  // GET /products/{id}/images  (sesuai soal)
  // -----------------------------
  Future<List<dynamic>> getProductImages(int idProduk) async {
    final url = Uri.parse("$baseUrl/products/$idProduk/images");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // -----------------------------
  // SAVE PRODUCT (create or update)
  // POST /products/save
  // jika edit sertakan id_produk
  // -----------------------------
  Future<Map<String, dynamic>> saveProduct({
    int? idProduk,
    required int idKategori,
    required String namaProduk,
    required int harga,
    required int stok,
    required String deskripsi,
  }) async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/products/save");

    try {
      final body = {
        if (idProduk != null) "id_produk": idProduk.toString(),
        "id_kategori": idKategori.toString(),
        "nama_produk": namaProduk,
        "harga": harga.toString(),
        "stok": stok.toString(),
        "deskripsi": deskripsi,
      };

      final res = await http.post(
        url,
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "message": "Gagal menyimpan produk: $e"};
    }
  }

  Future<Map<String, dynamic>> uploadProductImage({
  required int idProduk,
  }) async {
    // Karena tidak ada upload gambar,
    // kita langsung return success.
    return {
      "success": true,
      "message": "Upload gambar dimatikan (no-file mode)",
      "id_produk": idProduk
    };
  }

  // -----------------------------
  // DELETE PRODUCT
  // POST /products/{id}/delete
  // -----------------------------
  Future<Map<String, dynamic>> deleteProduct(int idProduk) async {
    final token = await _getToken();
    final url = Uri.parse("$baseUrl/products/$idProduk/delete");

    print("DELETE URL = $url");
    print("TOKEN = $token");

    try {
      final res = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("DELETE RESPONSE: ${res.body}");

      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "message": "Gagal menghapus produk: $e"};
    }
  }

  // =======================================================
  //  GET CATEGORIES
  // =======================================================
  Future<List<dynamic>> getCategories() async {
    final url = Uri.parse("$baseUrl/categories");

    try {
      final res = await http.get(url);

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        return data["data"]; // list kategori
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
