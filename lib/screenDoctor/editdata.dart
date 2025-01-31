import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenUser/newsetting.dart';

import '../screenUser/newitem.dart';

class DoctorEdit extends StatefulWidget {
  const DoctorEdit({super.key});

  @override
  State<DoctorEdit> createState() => _DoctorEditState();
}

class _DoctorEditState extends State<DoctorEdit> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isEdited = false; // ตัวแปรสำหรับตรวจสอบการแก้ไข

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _EmailController.text = userData['email'] ?? '';
        _usernameController.text = userData['username'] ?? '';
      }
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({
          'email': _EmailController.text,
          'username': _usernameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'ข้อมูลถูกอัปเดตเรียบร้อยแล้ว',
            style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
          )),
        );

        setState(() {
          _isEdited = false; // รีเซ็ตสถานะการแก้ไขหลังจากบันทึก
        });

        // นำทางกลับไปที่หน้า DoctorSetting
        Navigator.pop(context); // ถ้าต้องการกลับไปยังหน้าแรกใน Navigator stack
        // หรือใช้:
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const DoctorHome()),
        //   );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_isEdited) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'คุณได้ทำการแก้ไขข้อมูล',
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              content: Text(
                'ต้องการบันทึกการเปลี่ยนแปลงหรือไม่?',
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400)),
              ),
              actions: <Widget>[
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                                color: Colors.black, width: 2.5),
                            minimumSize: const Size(80, 45)),
                        child: Text('ไม่บันทึก',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton(
                        onPressed: _updateUserData,
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF5A85D9),
                            side: const BorderSide(
                                color: Color(0xFF5A85D9), width: 2.5),
                            minimumSize: const Size(80, 45)),
                        child: Text('บันทึก',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))),
                      )
                    ],
                  ),
                )
              ],
            ),
          ) ??
          false; // คืนค่าผลลัพธ์ของการกดปุ่ม
    }
    return true; // ถ้าไม่ได้แก้ไขให้ย้อนกลับ
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // จับการย้อนกลับ
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("แก้ไขข้อมูลส่วนตัว"),
          titleTextStyle: GoogleFonts.prompt(
              textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("อีเมล", style: promptStyle600_16),
                TextFormField(
                  controller: _EmailController,
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.edit, size: 18),
                    errorStyle: GoogleFonts.prompt(
                        textStyle: TextStyle(color: Colors.red, fontSize: 12)),
                    filled: true, // เปิดการใช้งานสีพื้นหลัง
                    fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาใส่อีเมล';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _isEdited = true; // เปลี่ยนสถานะเมื่อมีการแก้ไข
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text("ชื่อผู้ใช้งาน", style: promptStyle600_16),
                TextFormField(
                  controller: _usernameController,
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
                      return 'กรุณาใส่ชื่อผู้ใช้งาน';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _isEdited = true; // เปลี่ยนสถานะเมื่อมีการแก้ไข
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isEdited
                      ? _updateUserData
                      : null, // กดได้เมื่อ _isEdited เป็น true
                  style: ElevatedButton.styleFrom(
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 10, vertical: 10),
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: const Color(0xFF5A85D9)),
                  child: Text('บันทึก',
                      style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _EmailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
