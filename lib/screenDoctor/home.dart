import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

final TextStyle promptStyle = GoogleFonts.prompt(
  textStyle: const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
);

class DoctorHome extends StatefulWidget {
  const DoctorHome({super.key});

  @override
  State<DoctorHome> createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
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

  void _downloadPdf() async {
    const String pdfUrl =
        'https://drive.google.com/file/d/1tfAtfQWuf5c0dKcBTz12R1B5hkSQPcua/view?usp=drive_link';
    try {
      if (await canLaunch(pdfUrl)) {
        await launch(pdfUrl);
      } else {
        throw 'Could not launch $pdfUrl';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("หน้าหลัก"),
        titleTextStyle: GoogleFonts.prompt(
            textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        )),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
                // border:
                //     Border.all(color: const Color(0xFF5A85D9), width: 2)
              ),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "สวัสดี,",
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 16, color: Colors.grey)),
                      ),
                      Text(
                        "หมอ${_userData?['username']}",
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Image.asset("assets/images/pic1.png", width: 50, height: 50)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
              child: Text("กรุณาดาวน์โหลดมาร์กเกอร์ก่อนทำการถ่ายภาพ",
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600))),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: _downloadPdf,
                child: Row(
                  children: [
                    Text(
                      'ดาวน์โหลดมาร์กเกอร์',
                      style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 16, color: Color(0xFF5A85D9))),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(Icons.download,
                          size: 20, color: Color(0xFF5A85D9)),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset("assets/images/home.png")
          ],
        ),
      ),
    );
  }
}
