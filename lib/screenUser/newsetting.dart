import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenDoctor/editPassword.dart';
import 'package:newwieproject/screenUser/login.dart';
import 'package:newwieproject/screenUser/neweditdata.dart';
import 'package:newwieproject/screenUser/newitem.dart';
import 'package:shared_preferences/shared_preferences.dart';

final TextStyle promptStyle20_600 = GoogleFonts.prompt(
  textStyle: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
);
final TextStyle promptStyle22_600 = GoogleFonts.prompt(
  textStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
);

final TextStyle promptStyleNormal_15 = GoogleFonts.prompt(
  textStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  ),
);

final TextStyle promptStyle18_600 = GoogleFonts.prompt(
  textStyle: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
);

class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      // ดึง uid ของผู้ใช้ที่ล็อกอินอยู่
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // ดึงข้อมูลจาก Firestore โดยใช้ uid
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('user').doc(uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData =
                userDoc.data() as Map<String, dynamic>; // อัปเดต _userData
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ลบข้อมูลทั้งหมดใน SharedPreferences
    await FirebaseAuth.instance.signOut(); // ล็อกเอาท์จาก Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  // แสดง AlertDialog เมื่อกดปุ่มออกจากระบบ
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
              child: Text('ออกจากระบบของคุณใช่ไหม?', style: promptStyle600_16)),
          // content:
          //     Text('ออกจากระบบบัญชีของคุณใช่ไหม?', style: promptStyleNormal_15),
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
                        side: const BorderSide(color: Colors.black, width: 2.5),
                        minimumSize: const Size(80, 45)),
                    child: Text('ยกเลิก',
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _signOut();
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF5A85D9),
                        minimumSize: const Size(100, 45),
                        side: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5)),
                    child: Text('ออกจากระบบ',
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 70),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                // padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          _userData?['gender'] == "ชาย"
                              ? 'assets/images/pic7.png'
                              : 'assets/images/pic6.png',
                          width: 70,
                          height: 70,
                        ),
                        Text('${_userData?['username']}',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              FilledButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UserEdit()));
                  // print("Edit");
                },
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    textStyle: promptStyle600_16,
                    // minimumSize: const Size(400, 50),
                    padding: const EdgeInsets.all(15),
                    // minimumSize: const Size(350, 50),
                    foregroundColor: Colors.black),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        // SizedBox(width: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.person_outlined,
                              size: 22, color: Colors.black),
                        ),
                        // SizedBox(width: 20),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "แก้ไขข้อมูลส่วนตัว",
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.navigate_next_outlined,
                              size: 22, color: Colors.black),
                        )
                        // SizedBox(width: 50),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              FilledButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditPass()));
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      textStyle: promptStyle600_16,
                      // minimumSize: const Size(400, 50),
                      padding: const EdgeInsets.all(15),
                      foregroundColor: Colors.black),
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.lock_outline,
                            size: 22, color: Colors.black),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text("เปลี่ยนรหัสผ่าน"),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.navigate_next_outlined,
                            size: 22, color: Colors.black),
                      ),
                    ],
                  )),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                    onPressed: () {
                      _showSignOutDialog();
                    },
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color.fromRGBO(92, 86, 86, 0.165),
                            width: 2.5),
                        minimumSize: const Size.fromHeight(40)),
                    child: Text("ออกจากระบบ",
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red)))),
              ),
            ],
          ),
        ));
  }
}
