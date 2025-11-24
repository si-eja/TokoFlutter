import 'package:flutter/material.dart';
import 'package:toko_ku/api.service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage(this.profile, {super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController namaC;
  late TextEditingController userC;
  late TextEditingController kontakC;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: widget.profile["nama"]);
    userC = TextEditingController(text: widget.profile["username"]);
    kontakC = TextEditingController(text: widget.profile["kontak"]);
  }

  void updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final res = await api.updateProfile(
      namaC.text,
      userC.text,
      kontakC.text,
    );

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"] ?? "Gagal update")),
    );

    if (res["success"] == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // HEADER GRADIENT
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff2f58cd), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // CONTENT
          SafeArea(
            child: Column(
              children: [
                // BACK + TITLE
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Edit Profil",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                // AVATAR
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 55, color: Colors.black),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              buildInput(
                                icon: Icons.person,
                                label: "Nama",
                                controller: namaC,
                              ),
                              const SizedBox(height: 20),
                              buildInput(
                                icon: Icons.badge,
                                label: "Username",
                                controller: userC,
                              ),
                              const SizedBox(height: 20),
                              buildInput(
                                icon: Icons.phone,
                                label: "Kontak",
                                controller: kontakC,
                              ),

                              const SizedBox(height: 40),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2f58cd),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 8,
                                  ),
                                  onPressed: loading ? null : updateProfile,
                                  child: loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Simpan Perubahan",
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInput({
    required IconData icon,
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
