import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenUser/newitem.dart';

import '../screenUser/newsetting.dart';

final TextStyle promptStyle20_600 = GoogleFonts.prompt(
  textStyle: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
);

class EditPass extends StatefulWidget {
  const EditPass({super.key});

  @override
  State<EditPass> createState() => _EditPassState();
}

class _EditPassState extends State<EditPass> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isFormValid = false; // ตัวแปรสำหรับตรวจสอบความถูกต้องของฟอร์ม

  void _checkFormValidity() {
    setState(() {
      // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = _auth.currentUser;
        AuthCredential credential = EmailAuthProvider.credential(
            email: user!.email!, password: _currentPasswordController.text);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);

        Navigator.pop(context); // Close the progress dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(fontSize: 12)))),
        );

        Navigator.pop(context);

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } on FirebaseAuthException catch (error) {
        Navigator.pop(context); // Close the progress dialog
        String errorMessage = 'เกิดข้อผิดพลาด: ${error.message}';
        if (error.code == 'wrong-password') {
          errorMessage = 'รหัสผ่านปัจจุบันไม่ถูกต้อง';
        } else if (error.code == 'weak-password') {
          errorMessage = 'รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (error) {
        Navigator.pop(context); // Close the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาด: $error',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(fontSize: 12)))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("เปลี่ยนรหัสผ่าน"),
        titleTextStyle: GoogleFonts.prompt(
            textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("รหัสผ่านปัจจุบัน", style: promptStyle600_16),
              TextFormField(
                controller: _currentPasswordController,
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.prompt(
                      textStyle: TextStyle(color: Colors.red, fontSize: 12)),
                  suffixIcon: const Icon(Icons.edit, size: 18),
                  filled: true, // เปิดการใช้งานสีพื้นหลัง
                  fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รหัสผ่านปัจจุบัน';
                  }
                  return null;
                },
                onChanged: (value) =>
                    _checkFormValidity(), // เช็คความถูกต้องเมื่อมีการเปลี่ยนแปลง
              ),
              const SizedBox(height: 20),
              Text("รหัสผ่านใหม่", style: promptStyle600_16),
              TextFormField(
                controller: _newPasswordController,
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.prompt(
                      textStyle: TextStyle(color: Colors.red, fontSize: 12)),
                  suffixIcon: const Icon(Icons.edit, size: 18),
                  filled: true, // เปิดการใช้งานสีพื้นหลัง
                  fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาใส่รหัสผ่านใหม่';
                  }
                  if (value.length < 6) {
                    return 'รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  return null;
                },
                onChanged: (value) =>
                    _checkFormValidity(), // เช็คความถูกต้องเมื่อมีการเปลี่ยนแปลง
              ),
              const SizedBox(height: 20),
              Text("ยืนยันรหัสผ่านใหม่", style: promptStyle600_16),
              TextFormField(
                controller: _confirmPasswordController,
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black)),
                decoration: InputDecoration(
                  errorStyle: GoogleFonts.prompt(
                      textStyle: TextStyle(color: Colors.red, fontSize: 12)),
                  suffixIcon: const Icon(Icons.edit, size: 18),
                  filled: true, // เปิดการใช้งานสีพื้นหลัง
                  fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณายืนยันรหัสผ่านใหม่';
                  }
                  if (value != _newPasswordController.text) {
                    return 'รหัสผ่านไม่ตรงกัน';
                  }
                  return null;
                },
                onChanged: (value) =>
                    _checkFormValidity(), // เช็คความถูกต้องเมื่อมีการเปลี่ยนแปลง
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isFormValid
                    ? _changePassword
                    : null, // ปุ่มจะทำงานได้เมื่อฟอร์มถูกต้อง
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  minimumSize: const Size.fromHeight(40),
                  backgroundColor: const Color(0xFF5A85D9),
                ),
                child: Text(
                  'บันทึก',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
