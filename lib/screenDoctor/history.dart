import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:newwieproject/screenDoctor/camera.dart';
import 'package:newwieproject/screenDoctor/detail.dart';
import 'package:newwieproject/screenDoctor/editPatient.dart';
import 'package:http/http.dart' as http;
import 'package:newwieproject/screenUser/newitem.dart';

final TextStyle promptStyle600_18 = GoogleFonts.prompt(
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600));

final TextStyle promptStyle600_16 = GoogleFonts.prompt(
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));

class PatientDetailStateful extends StatefulWidget {
  final String patientId;
  final String hn;

  const PatientDetailStateful(
      {super.key, required this.patientId, required this.hn});

  @override
  _PatientDetailState createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetailStateful> {
  bool _isDeletingMode = false; // ตัวแปรสำหรับโหมดลบ
  final List<String> _selectedItems = []; // รายการที่ถูกเลือก

  // ดึงข้อมูลรูปภาพและรายละเอียดจากคอลเล็กชัน photo
  Stream<QuerySnapshot> _getPhotos() {
    String? doctorId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('user')
        .doc(doctorId)
        .collection('patients')
        .doc(widget.patientId)
        .collection('photo')
        .where('isHidden', isEqualTo: false)
        .snapshots();
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'มกราคม';
      case 2:
        return 'กุมภาพันธ์';
      case 3:
        return 'มีนาคม';
      case 4:
        return 'เมษายน';
      case 5:
        return 'พฤษภาคม';
      case 6:
        return 'มิถุนายน';
      case 7:
        return 'กรกฎาคม';
      case 8:
        return 'สิงหาคม';
      case 9:
        return 'กันยายน';
      case 10:
        return 'ตุลาคม';
      case 11:
        return 'พฤศจิกายน';
      case 12:
        return 'ธันวาคม';
      default:
        return '';
    }
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeletingMode = !_isDeletingMode;
      _selectedItems.clear(); // เคลียร์รายการที่เลือกเมื่อเปลี่ยนโหมด
    });
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (_selectedItems.contains(docId)) {
        _selectedItems.remove(docId); // ลบรายการออกถ้าถูกเลือกแล้ว
      } else {
        _selectedItems.add(docId); // เพิ่มรายการถ้าไม่ได้เลือก
      }
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
              child: Text("ยืนยันการลบ",
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)))),
          content: Text("คุณต้องการลบรายการที่เลือกหรือไม่?",
              style: GoogleFonts.prompt(
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400))),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: OutlinedButton.styleFrom(
                        // padding: const EdgeInsets.all(10),
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
                    onPressed: () async {
                      try {
                        // ดำเนินการลบรายการที่เลือก
                        for (String docId in _selectedItems) {
                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('patients')
                              .doc(widget.patientId)
                              .collection('photo')
                              .doc(docId)
                              .update({'isHidden': true});
                        }

                        // แสดงข้อความหลังจากลบรายการเสร็จ
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('ลบข้อมูลสำเร็จ',
                                style: GoogleFonts.prompt(
                                    textStyle:
                                        const TextStyle(fontSize: 14)))));

                        // กลับไปยังหน้าก่อนหน้า
                        Navigator.of(context).pop();
                        _toggleDeleteMode();
                      } catch (e) {
                        // แสดงข้อผิดพลาดหากเกิดปัญหา
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('เกิดข้อผิดพลาด: $e',
                                  style: GoogleFonts.prompt(
                                      textStyle:
                                          const TextStyle(fontSize: 14)))),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                        // padding: const EdgeInsets.all(10),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF5A85D9),
                        side: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5),
                        minimumSize: const Size(80, 45)),
                    child: Text('ลบ',
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

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
          // print('Failed to process image through API.');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('การประมวลผลที่ API ผิดพลาด',
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(fontSize: 12)))));
        }
      } catch (e) {
        // print('Failed to upload image: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('การอัปโหลดผิดพลาด: $e',
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
          'photo_doctors/$widget.patientId/${DateTime.now().millisecondsSinceEpoch}.jpg');

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
        print('อัปโหลดภาพเสร็จสิ้น ดาวน์โหลด URL: $downloadUrl');

        // สมมติว่าเราต้องการบันทึก URL ลงใน Firestore ด้วย
        await FirebaseFirestore.instance
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('patients')
            .doc(widget.patientId)
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.hn,
          style: GoogleFonts.prompt(
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            width: 40,
            height: 40,
            child: PopupMenuButton<String>(
              onSelected: (String result) async {
                if (result == 'กล้อง') {
                  // _openCamera();
                  // String? doctorId = FirebaseAuth.instance.currentUser?.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CameraDoctor(patientId: widget.patientId)),
                  );
                } else if (result == 'แก้ไขข้อมูล') {
                  String? doctorId = FirebaseAuth.instance.currentUser?.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorEditpatient(
                        uid: doctorId ??
                            '', // ถ้า doctorId เป็น null จะส่งเป็นค่าว่าง
                        patientId: widget.patientId, // ส่ง patientId จาก widget
                      ),
                    ),
                  );
                } else if (result == 'ลบรายการ') {
                  // print('ลบรายการ'); // แสดงหน้าต่างยืนยันการลบ
                  _toggleDeleteMode();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'กล้อง',
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'กล้อง',
                          style: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 3),
                PopupMenuItem<String>(
                  value: 'แก้ไขข้อมูล',
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text('แก้ไขข้อมูล',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))),
                      ],
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 3),
                PopupMenuItem<String>(
                  value: 'ลบรายการ',
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text('ลบรายการ',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal))),
                      ],
                    ),
                  ),
                ),
              ],
              icon: const Icon(
                Icons.dehaze,
                color: Colors.black,
                size: 22,
              ),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 8,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle,
                    color: Colors.green, // สีของไอคอน
                    size: 18),
                SizedBox(width: 5), // เว้นระยะห่างระหว่างไอคอนและข้อความ
                Text("ปกติ", // ข้อความที่แสดง
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal))),
                SizedBox(width: 5),
                Icon(Icons.circle,
                    color: Colors.amber, // สีของไอคอน
                    size: 16),
                SizedBox(width: 5), // เว้นระยะห่างระหว่างไอคอนและข้อความ
                Text("เล็กน้อย", // ข้อความที่แสดง
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal))),
                SizedBox(width: 5),
                Icon(Icons.circle,
                    color: Colors.orange, // สีของไอคอน
                    size: 16),
                SizedBox(width: 5), // เว้นระยะห่างระหว่างไอคอนและข้อความ
                Text("ปานกลาง", // ข้อความที่แสดง
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal))),
                SizedBox(width: 5),
                Icon(Icons.circle,
                    color: Colors.red, // สีของไอคอน
                    size: 16),
                SizedBox(width: 5), // เว้นระยะห่างระหว่างไอคอนและข้อความ
                Text("อันตราย", // ข้อความที่แสดง
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black))),
                SizedBox(width: 5), // เว้นระยะห่างระหว่างไอคอนและข้อความ
                Icon(Icons.circle,
                    color: Colors.black, // สีของไอคอน
                    size: 16),
                SizedBox(width: 5),
                Text("ค่าไม่ปกติ", // ข้อความที่แสดง
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal)))
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getPhotos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('เกิดข้อผิดพลาด',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400))));
                  }
                  if (snapshot.data?.docs.isEmpty ?? true) {
                    return Center(
                        child: Text('ไม่มีประวัติ',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400))));
                  }
                  List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
                  sortedDocs.sort((a, b) {
                    Timestamp timestampA = a['timestamp'] as Timestamp;
                    Timestamp timestampB = b['timestamp'] as Timestamp;
                    return timestampB
                        .compareTo(timestampA); // เรียงจากใหม่ไปเก่า
                  });

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      // DocumentSnapshot doc = snapshot.data!.docs[index];
                      DocumentSnapshot doc = sortedDocs[index];
                      String docId = doc.id;
                      String photoUrl = doc['url'];

                      // แปลงค่า cva และ fsp เป็นทศนิยมสองตำแหน่ง ถ้าไม่มีค่าให้แสดง N/A
                      final cva = doc['cva'] != null
                          ? double.parse(doc['cva'].toString())
                              .toStringAsFixed(2)
                          : 'N/A';
                      final fsp = doc['fsp'] != null
                          ? double.parse(doc['fsp'].toString())
                              .toStringAsFixed(2)
                          : 'N/A';

                      // ดึงค่า timestamp และแปลงเป็น DateTime
                      final Timestamp timestamp = doc['timestamp'] as Timestamp;
                      final DateTime date = timestamp.toDate();

                      // แปลงปีจาก ค.ศ. เป็น พ.ศ.
                      final buddhistYear = (date.year + 543) % 100;
                      final fourYear = (date.year + 543);
                      final formattedDate = DateFormat()
                          .addPattern('dd/MM/$buddhistYear')
                          .addPattern('| kk:mm น.')
                          .format(date);
                      final onlydate = DateFormat()
                          .addPattern('dd MMMM $fourYear')
                          .format(date);
                      final onlytime =
                          DateFormat().addPattern('kk:mm น.').format(date);
                      String formatted =
                          '${date.day} ${_getMonthName(date.month)} ${date.year + 543}';

                      return Column(
                        children: [
                          FilledButton(
                            onPressed: () {
                              if (_isDeletingMode) {
                                _toggleSelection(docId);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DoctorDetail(
                                            photoUrl: photoUrl,
                                            cva: cva,
                                            fsp: fsp,
                                            onlydate: onlydate,
                                            onlytime: onlytime,
                                            formatted: formatted)));
                                // โค้ดเปิดรายละเอียดผู้ป่วย
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: _isDeletingMode &&
                                        _selectedItems.contains(docId)
                                    ? Colors.red
                                    : const Color(0xFF5A85D9),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.network(
                                  photoUrl,
                                  width: 80,
                                  height: 100,
                                ),
                                const SizedBox(width: 50),
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: (doc['cva'] != null)
                                            ? (doc['cva'] >= 32 &&
                                                    doc['cva'] < 43
                                                ? Colors.red
                                                : (doc['cva'] >= 43 &&
                                                        doc['cva'] < 47
                                                    ? Colors.orange
                                                    : (doc['cva'] >= 47 &&
                                                            doc['cva'] <= 50
                                                        ? Colors.amber
                                                        : (doc['cva'] > 50
                                                            ? Colors.black
                                                            : Colors.green))))
                                            : Colors
                                                .grey, // กรณีที่ cva ไม่มีค่า
                                      ),
                                      margin: const EdgeInsets.all(5),
                                      width: 140,
                                      height: 30,
                                      child: Center(
                                        child: Text("CVA : $cva°",
                                            style: promptStyle600_14),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: (doc['fsp'] != null)
                                              ? (doc['fsp'] < 52
                                                  ? Colors.orange
                                                  : Colors.green)
                                              : Colors.grey),
                                      margin: const EdgeInsets.all(5),
                                      width: 140,
                                      height: 30,
                                      child: Center(
                                        child: Text("FSA : $fsp°",
                                            style: promptStyle600_14),
                                      ),
                                    ),
                                    Text(formattedDate,
                                        style: GoogleFonts.prompt(
                                            textStyle: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.black))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (_isDeletingMode)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 35,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _toggleDeleteMode,
                        child: Text(
                          "ยกเลิก",
                          style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF5A85D9)),
                          ),
                        ),
                      ),
                      Text(
                        'เลือกอยู่ ${_selectedItems.length} รายการ',
                        style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: _selectedItems.isNotEmpty
                            ? () => _confirmDelete(context)
                            : null,
                        child: Icon(
                          Icons.delete,
                          size: 22,
                          color: _selectedItems.isNotEmpty
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
