import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenAdmin/adminBar.dart';
import 'package:newwieproject/screenDoctor/doctorBar.dart';
import 'package:newwieproject/screenUser/register.dart';
import 'package:newwieproject/screenUser/userBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

final TextStyle promptStyle5 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),
);
final TextStyle promptStyle16 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _validateemail(String? value) {
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
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          // บันทึก userUid ลงใน SharedPreferences เพื่อใช้งานในครั้งถัดไป
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userUid', userCredential.user!.uid);

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('user')
              .doc(userCredential.user!.uid)
              .get();

          String? role = userDoc['role'];

          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AdminBar(Adminuid: userCredential.user!.uid),
              ),
            );
          } else if (role == 'doctor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DoctorBar(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserBar()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          if (e.code == 'user-not-found') {
            _errorMessage = 'ไม่พบบัญชีผู้ใช้นี้';
          } else if (e.code == 'wrong-password') {
            _errorMessage = 'รหัสผ่านไม่ถูกต้อง';
          } else {
            _errorMessage = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
          }
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'กรุณาใส่อีเมลและรหัสผ่าน';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString('userUid');

    if (userUid != null) {
      // ถ้ามี userUid ใน SharedPreferences แสดงว่าผู้ใช้ล็อกอินแล้ว
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(userUid)
          .get();

      String? role = userDoc['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminBar(Adminuid: userUid),
          ),
        );
      } else if (role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DoctorBar(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserBar()),
        );
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5A85D9),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/images/2.jpg"), // replace with your asset image
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30.0),
                margin: EdgeInsets.only(
                  bottom: isKeyboardVisible
                      ? MediaQuery.of(context).viewInsets.bottom
                      : 0,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "ยินดีต้อนรับ",
                          style: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ),
                        Text('เข้าสู่ระบบเพื่อดำเนินการ',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal))),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
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
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 2.5),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 10),
                              hintText: 'อีเมล',
                              hintStyle: GoogleFonts.prompt(
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF2E2E2E)))),
                          validator: _validateemail,
                          style: promptStyle16,
                          // forceErrorText: _errorMessage,
                        ),
                        const SizedBox(height: 15),
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
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.5),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 2.5),
                                ),
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 10),
                                hintText: 'รหัสผ่าน',
                                hintStyle: GoogleFonts.prompt(
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF2E2E2E)))),
                            obscureText: true,
                            validator: _validatePassword,
                            style: promptStyle16),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                            backgroundColor:
                                const Color.fromRGBO(90, 133, 217, 1),
                          ),
                          child: Text('เข้าสู่ระบบ',
                              style: GoogleFonts.prompt(
                                  textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white))),
                        ),
                        if (_errorMessage != null && _errorMessage!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.prompt(
                                textStyle:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(children: [
                                    Text(
                                      'ยังไม่มีบัญชี?',
                                      style: GoogleFonts.prompt(
                                          textStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return const Register();
                                          },
                                        ));
                                      },
                                      child: Text('ลงทะเบียนที่นี่',
                                          style: GoogleFonts.prompt(
                                              textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xFF5A85D9)))),
                                    ),
                                  ]),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
