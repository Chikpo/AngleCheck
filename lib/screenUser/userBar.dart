import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newwieproject/screenUser/camera.dart';
import 'package:newwieproject/screenUser/newhome.dart';
import 'package:newwieproject/screenUser/newitem.dart';
import 'package:newwieproject/screenUser/newsetting.dart';
import 'package:http/http.dart' as http;

class UserBar extends StatefulWidget {
  const UserBar({super.key});

  @override
  State<UserBar> createState() => _UserBarState();
}

class _UserBarState extends State<UserBar> {
  int _currentIndex = 0;
  final screen = const [NewHome(), UserItem(), null, UserSetting()];
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // ฟังก์ชันขอสิทธิ์การเข้าถึง

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      try {
        final file = File(pickedFile.path);

        // เรียกใช้งานฟังก์ชัน uploadImageToFirebase และส่งค่าที่ได้รับจาก API
        const apiUrl =
            'http://prepro2.informatics.buu.ac.th:8065/process-image/';
        final imageBytes = await file.readAsBytes();
        final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
              filename: 'image.jpg'));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.toBytes();
          final cva = response.headers['cva'];
          final fsp = response.headers['fsp'];

          double? cvaValue = cva != null ? double.tryParse(cva) : null;
          double? fspValue = fsp != null ? double.tryParse(fsp) : null;

          if (cvaValue != null && fspValue != null) {
            // เรียกใช้งาน uploadImageToFirebaseFromApi
            await uploadImageToFirebaseFromApi(
                responseBody, cvaValue, fspValue);
          } else {
            print('Failed to parse cva or fsa');
          }
        } else {
          print('Failed to process image through API.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to process image through API.',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(fontSize: 12)))));
        }
      } catch (e) {
        // print('Failed to upload image: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('อัปโหลดภาพไม่สำเร็จ: $e',
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(fontSize: 12)))));
      }
    } else {
      // print('No image selected.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ไม่ได้เลือกภาพ',
              style: GoogleFonts.prompt(
                  textStyle: const TextStyle(fontSize: 12)))));
    }
  }

// ฟังก์ชันสำหรับอัพโหลดภาพไปที่ Firebase Storage
  Future<void> uploadImageToFirebaseFromApi(
      List<int> responseBody, double cvaValue, double fspValue) async {
    try {
      // ตรวจสอบประเภทข้อมูลก่อน
      // สร้าง Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref().child(
          'photo_users/$_userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // เริ่มการอัปโหลดข้อมูล
      final uploadTask = storageRef.putData(
          Uint8List.fromList(responseBody)); // ใช้ Uint8List จาก List<int>

      // รอให้การอัปโหลดเสร็จสิ้น
      final snapshot = await uploadTask.whenComplete(() => null);

      // ตรวจสอบสถานะการอัปโหลด
      if (snapshot.state == TaskState.success) {
        // ได้รับ URL ของไฟล์ที่อัปโหลดสำเร็จ
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // คุณสามารถเก็บ URL นี้ใน Firestore หรือทำอย่างอื่นได้
        print('Image uploaded successfully. Download URL: $downloadUrl');

        // สมมติว่าเราต้องการบันทึก URL ลงใน Firestore ด้วย
        await FirebaseFirestore.instance
            .collection('user')
            .doc(_userId)
            .collection('photo')
            .add({
          'url': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'cva': cvaValue,
          'fsp': fspValue,
          'isHidden': false,
        });

        print('Data successfully saved to Firestore');
      } else {
        print('Failed to upload image to Firebase Storage');
      }
    } catch (e) {
      print('Error during upload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: screen[_currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          iconSize: 25,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: const Color(0xFF5A85D9),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: "History",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: "Camera",
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3
                  ? Icons.settings
                  : Icons.settings_outlined),
              label: "Setting",
            ),
          ],
          onTap: (newIndex) {
            setState(() {
              if (newIndex == 2) {
                // หากคลิกที่กล้อง ให้เปิดกล้อง
                // _openCamera();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraWithSquareOverlay()
                  ),
                );
              } else {
                _currentIndex = newIndex;
              }
            });
          },
        ));
  }
}
