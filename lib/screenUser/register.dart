import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login.dart';

final TextStyle promptStyle600_16 = GoogleFonts.prompt(
  textStyle: const TextStyle(fontSize: 16, color: Colors.black),
);

final TextStyle promptStyle4 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),
);
final TextStyle promptStyle600_14 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 14, color: Colors.black, fontWeight: FontWeight.w400),
);

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnteredPasswordController =
      TextEditingController();
  String? _selectedGender;
  bool _genderError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่อีเมล';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'กรุณาใส่อีเมลที่ถูกต้อง';
    }
    return null;
  }

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่ชื่อผู้ใช้งาน';
    }
    return null;
  }

  // String? _validateSurname(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'กรุณาใส่นามสกุล';
  //   }
  //   return null;
  // }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่อายุ';
    }
    if (int.tryParse(value) == null) {
      return 'กรุณาใส่อายุที่ถูกต้อง';
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

  String? _validateReEnteredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณายืนยันรหัสผ่าน';
    }
    if (value != _passwordController.text) {
      return 'รหัสผ่านไม่ตรงกัน';
    }
    return null;
  }

  Future<void> _register() async {
    setState(() {
      _genderError = _selectedGender == null;
    });

    if (_formKey.currentState!.validate() && _selectedGender != null) {
      String email = _EmailController.text;
      String password = _passwordController.text;
      String username = _usernameController.text;
      // String surname = _surnameController.text;
      int age = int.parse(_ageController.text);
      String gender = _selectedGender!;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection('user')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'username': username,
          'age': age,
          'gender': gender,
          'role': 'user'
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'ลงทะเบียนเรียบร้อยแล้ว',
            style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
          )),
        );

        Navigator.pop(context); // Close the progress dialog

        // Navigator.pushReplacement(context, MaterialPageRoute(
        //   builder: (context) {
        //     return const Login();
        //   },
        // )
        // );

        _EmailController.clear();
        _usernameController.clear();
        _ageController.clear();
        _passwordController.clear();
        _reEnteredPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // Close the progress dialog
        String message = 'เกิดข้อผิดพลาดในการสมัครสมาชิก';
        if (e.code == 'email-already-in-use') {
          message = 'อีเมลนี้ถูกใช้ไปแล้ว';
        } else if (e.code == 'weak-password') {
          message = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        Navigator.pop(context); // Close the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาด: ${e.toString()}',
                  style: GoogleFonts.prompt(
                      textStyle:
                          const TextStyle(fontSize: 12, color: Colors.red)))),
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
        elevation: 0,
        title: Text('ลงทะเบียน',
            style: GoogleFonts.prompt(
                textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          hintText: 'อีเมล',
                          hintStyle: promptStyle600_14,
                          errorStyle: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.red))),
                      validator: _validateEmail,
                      style: promptStyle600_14),
                  const SizedBox(height: 20.0),
                  TextFormField(
                      controller: _usernameController,
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          hintText: 'ชื่อผู้ใช้งาน',
                          hintStyle: promptStyle600_14,
                          errorStyle: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.red))),
                      validator: _validateUserName,
                      style: promptStyle600_14),
                  const SizedBox(height: 20.0),
                  TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          hintText: 'อายุ',
                          hintStyle: promptStyle600_14,
                          errorStyle: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.red))),
                      validator: _validateAge,
                      style: promptStyle600_14),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text('เพศ', style: promptStyle600_14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: _selectedGender == 'หญิง'
                                  ? Colors.white
                                  : Colors.black,
                              backgroundColor: _selectedGender == 'หญิง'
                                  ? const Color(0xFF5A85D9)
                                  : Colors.white,
                              side: BorderSide(
                                  color: _selectedGender == 'หญิง'
                                      ? const Color(0xFF5A85D9)
                                      : const Color(0x2A5C5656),
                                  width: 2.5),
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedGender = 'หญิง';
                                _genderError = false;
                              });
                            },
                            child: Text('หญิง',
                                style: GoogleFonts.prompt(
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)))),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: _selectedGender == 'ชาย'
                                ? Colors.white
                                : Colors.black,
                            backgroundColor: _selectedGender == 'ชาย'
                                ? const Color(0xFF5A85D9)
                                : Colors.white,
                            side: BorderSide(
                                color: _selectedGender == 'ชาย'
                                    ? const Color(0xFF5A85D9)
                                    : const Color(0x2A5C5656),
                                width: 2.5),
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedGender = 'ชาย';
                              _genderError = false;
                            });
                          },
                          child: Text('ชาย',
                              style: GoogleFonts.prompt(
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400))),
                        ),
                      )
                    ],
                  ),
                  Visibility(
                    visible: _genderError,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'กรุณาเลือกเพศ',
                          style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                      controller: _passwordController,
                      obscureText: true,
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          hintText: 'รหัสผ่าน',
                          hintStyle: promptStyle600_14,
                          errorStyle: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.red))),
                      validator: _validatePassword,
                      style: promptStyle600_14),
                  const SizedBox(height: 20.0),
                  TextFormField(
                      controller: _reEnteredPasswordController,
                      obscureText: true,
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
                          contentPadding:
                              const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          hintText: 'ยืนยันรหัสผ่าน',
                          hintStyle: promptStyle600_14,
                          errorStyle: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 10, color: Colors.red))),
                      validator: _validateReEnteredPassword,
                      style: promptStyle600_14),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        // padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        backgroundColor: const Color(0xFF5A85D9),
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text('ลงทะเบียน',
                          style: GoogleFonts.prompt(
                              textStyle: (const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
