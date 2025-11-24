import 'package:flutter/material.dart';
import '../api.service.dart';

class EditProfilePage extends StatefulWidget {
  final Map profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ApiService api = ApiService();

  late TextEditingController nameCtrl;
  late TextEditingController userCtrl;
  late TextEditingController kontakCtrl;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.profile["name"]);
    userCtrl = TextEditingController(text: widget.profile["username"]);
    kontakCtrl = TextEditingController(text: widget.profile["kontak"]);
  }
  
  void saveEdit() async {
    setState(() => loading = true);

    final res = await api.updateProfile(
      name: nameCtrl.text,
      username: userCtrl.text,
      kontak: kontakCtrl.text,
    );

    setState(() => loading = false);

    if (res["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile berhasil diperbarui")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade700, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          children: [
            textField("Nama", nameCtrl),
            SizedBox(height: 12),
            textField("Username", userCtrl),
            SizedBox(height: 12),
            textField("Kontak", kontakCtrl, phone: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : saveEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Simpan", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget textField(String label, TextEditingController c, {bool phone = false}) {
    return TextField(
      controller: c,
      keyboardType: phone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}
