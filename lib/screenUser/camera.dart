import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraWithSquareOverlay extends StatefulWidget {
  @override
  _CameraWithSquareOverlayState createState() =>
      _CameraWithSquareOverlayState();
}

class _CameraWithSquareOverlayState extends State<CameraWithSquareOverlay> {
  CameraController? _cameraController;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;
  XFile? _imageFile;
  bool _isImageTaken = false; // สถานะการถ่ายภาพ
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // ดึงข้อมูลกล้องทั้งหมด
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras[0], // ใช้กล้องตัวแรก (กล้องหลัง)
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      setState(() {
        _imageFile = image; // เก็บภาพที่ถ่าย
        _isImageTaken = true; // ตั้งค่าสถานะว่าได้ถ่ายภาพแล้ว
      });
      print('Image saved at: ${image.path}');
    }
  }

  Future<void> _confirm() async {
    // ฟังก์ชันยืนยันการเลือกภาพเมื่อกดเครื่องหมายถูก
    if (_imageFile != null) {
      try {
        final file = File(_imageFile!.path);

        // เรียกใช้ฟังก์ชัน uploadImageToFirebaseFromApi และส่งค่าที่ได้รับจาก API
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
            print('Failed to parse cva or fsp');
          }
        } else {
          print('Failed to process image through API.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to process image through API.',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(fontSize: 12)))));
        }

        // หลังจากอัปโหลดเสร็จแล้ว กลับไปยังหน้าก่อน
        Navigator.pop(context);
      } catch (e) {
        print('Error during image upload: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('อัปโหลดภาพไม่สำเร็จ: $e',
                style: GoogleFonts.prompt(
                    textStyle: const TextStyle(fontSize: 12)))));
      }
    }
  }

  Future<void> _cancel() async {
    // ฟังก์ชันยกเลิกการเลือกภาพ
    setState(() {
      _imageFile = null;
      _isImageTaken = false; // เปลี่ยนสถานะกลับ
    });
    print('Image selection canceled');
  }

  Future<void> uploadImageToFirebaseFromApi(
      List<int> responseBody, double cvaValue, double fspValue) async {
    try {
      // สร้าง Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref().child(
          'photo_users/$_userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // เริ่มการอัปโหลดข้อมูล
      final uploadTask = storageRef.putData(
          Uint8List.fromList(responseBody)); // ใช้ Uint8List จาก List<int>

      // รอให้การอัปโหลดเสร็จสิ้น
      final snapshot = await uploadTask.whenComplete(() => null);

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('Image uploaded successfully. Download URL: $downloadUrl');

        // บันทึก URL ลงใน Firestore
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
      body: Stack(
        children: [
          // กล้อง
          isCameraInitialized
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator()),

          // กรอบสี่เหลี่ยม
          Center(
            child: Container(
              width: 250,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),

          // ถ้าเลือกภาพแล้ว แสดงภาพที่ถ่าย
          if (_imageFile != null)
            Center(
              child: Image.file(
                File(_imageFile!.path),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          // แถบด้านล่างที่มีปุ่มเครื่องหมายถูกและกากบาท
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ถ้าไม่ถ่ายภาพ จะแสดงปุ่มถ่ายภาพ
                  if (!_isImageTaken)
                    IconButton(
                      onPressed: _takePicture,
                      icon:
                          Icon(Icons.camera_alt, color: Colors.white, size: 60),
                    ),
                  // ถ้าถ่ายภาพแล้ว จะแสดงปุ่มยืนยันและยกเลิก
                  if (_isImageTaken) ...[
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context); // กลับไปหน้าก่อน
                      },
                      icon: Icon(Icons.arrow_circle_left,
                          color: Colors.white, size: 60),
                    ),
                    // ปุ่มยืนยัน
                    IconButton(
                      onPressed: _confirm,
                      icon: Icon(Icons.check_circle,
                          color: Colors.white, size: 60),
                    ),
                    // ปุ่มยกเลิก
                    IconButton(
                      onPressed: _cancel,
                      icon: Icon(Icons.cancel, color: Colors.white, size: 60),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
