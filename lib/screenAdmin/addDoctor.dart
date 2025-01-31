import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenDoctor/addform.dart';
import 'package:newwieproject/screenDoctor/history.dart';
import 'package:newwieproject/screenDoctor/home.dart';

final TextStyle promptStyle20 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF2E2E2E)),
);

class AdminAddDoctor extends StatefulWidget {
  final String Adminuid;
  const AdminAddDoctor({super.key, required this.Adminuid});

  @override
  State<AdminAddDoctor> createState() => _AdminAddDoctorState();
}

class _AdminAddDoctorState extends State<AdminAddDoctor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่ชื่อ';
    }
    return null;
  }

  String? _validateSurname(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่นามสกุล';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่อีเมล';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'กรุณาใส่อีเมลที่ถูกต้อง';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่รหัสผ่าน';
    }
    if (value.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }
    return null;
  }

  // String? get nuid => _auth.currentUser?.uid; // Correctly getting the UID
  String? newuid;

  Future<void> _addDoctor() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String surname = _surnameController.text;
      String email = _EmailController.text;
      String password = _passwordController.text;

      try {
        // ดึง role ของผู้ใช้ปัจจุบัน
        // User? user = FirebaseAuth.instance.currentUser;
        // final String aduid = user!.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.Adminuid) // uid ของผู้ใช้ปัจจุบัน
            .get();

        // ตรวจสอบว่า role ของผู้ใช้เป็น admin หรือไม่
        if (userDoc.exists && userDoc['role'] == 'admin') {
          // แสดง Dialog โหลดข้อมูล
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          // เก็บข้อมูลในคอลเล็กชันย่อย /user/uid/doctors
          // สร้างบัญชีผู้ใช้ใหม่ใน Firebase Authentication
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

// ใช้ UID ที่ได้จากการสร้างผู้ใช้ใหม่ใน Firebase Authentication
          String newuid = userCredential.user!.uid;

// สร้างเอกสารในคอลเล็กชัน 'doctors' โดยใช้ newuid เป็น UID
          await FirebaseFirestore.instance
              .collection('user')
              .doc(widget.Adminuid) // uid ของผู้ใช้ปัจจุบัน
              .collection('doctors')
              .doc(newuid) // ใช้ newuid ที่ถูกสร้างขึ้น
              .set({
            'name': name,
            'surname': surname,
            'email': email,
            'password': password,
            'role': 'doctor'
          });

// สร้างเอกสารในคอลเล็กชัน 'user' โดยใช้ newuid เป็น UID
          await FirebaseFirestore.instance
              .collection('user')
              .doc(newuid) // ใช้ newuid ที่ถูกสร้างขึ้น
              .set({
            'email': email,
            'username': name,
            'role': 'doctor',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'เพิ่มหมอเรียบร้อยแล้ว',
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(fontSize: 12)),
              ),
            ),
          );

          Navigator.pop(context); // ปิด Dialog

          // ล้างข้อมูลใน TextField
          _nameController.clear();
          _surnameController.clear();
          _EmailController.clear();
          _passwordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('สิทธิ์ไม่เพียงพอในการเพิ่มข้อมูล',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(fontSize: 12)))));
        }
      } on FirebaseException catch (e) {
        Navigator.pop(context); // ปิด Dialog
        String message = 'เกิดข้อผิดพลาดในการเพิ่มหมอ';

        if (e.code == 'email-already-in-use') {
          message = 'Email นี้ถูกใช้ไปแล้ว';
        } else if (e.code == 'invalid-email') {
          message = 'กรอก Email ไม่ถูกต้อง';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        Navigator.pop(context); // ปิด Dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาด: ${e.toString()}',
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
        title: const Text("เพิ่มหมอ"),
        titleTextStyle: GoogleFonts.prompt(
            textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ชื่อ", style: promptStyle600_16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 2.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      errorStyle: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 12, color: Colors.red))),
                  validator: _validateName,
                  style: promptStyle6,
                ),
                const SizedBox(height: 20),
                Text("นามสกุล", style: promptStyle600_16),
                TextFormField(
                  controller: _surnameController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 2.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      errorStyle: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 12, color: Colors.red))),
                  validator: _validateSurname,
                  style: promptStyle6,
                ),
                const SizedBox(height: 20),
                Text("อีเมล", style: promptStyle600_16),
                TextFormField(
                  controller: _EmailController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 2.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      errorStyle: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 12, color: Colors.red))),
                  validator: _validateEmail,
                  style: promptStyle6,
                ),
                const SizedBox(height: 20),
                Text("รหัสผ่าน", style: promptStyle600_16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0), width: 2.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide:
                            const BorderSide(color: Colors.red, width: 2.5),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      errorStyle: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 12, color: Colors.red))),
                  validator: _validatePassword,
                  style: promptStyle6,
                ),
                const SizedBox(height: 20),
                FilledButton(
                    onPressed: _addDoctor,
                    style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF5A85D9),
                        textStyle: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        minimumSize: const Size.fromHeight(40)),
                    child: const Text("เพิ่มหมอ")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
