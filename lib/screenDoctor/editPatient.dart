import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenDoctor/history.dart';
// import 'package:newwieproject/screenUser/newsetting.dart';

class DoctorEditpatient extends StatefulWidget {
  final String uid;
  final String patientId;

  const DoctorEditpatient({
    super.key,
    required this.uid,
    required this.patientId,
  });

  @override
  State<DoctorEditpatient> createState() => _DoctorEditpatientState();
}

class _DoctorEditpatientState extends State<DoctorEditpatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hnController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = '';
  bool _isEdited = false;
  final bool _genderError = false;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (patientDoc.exists) {
        Map<String, dynamic> patientData =
            patientDoc.data() as Map<String, dynamic>;

        setState(() {
          _hnController.text = patientData['HN']?.toString() ?? ''; // แสดง HN
          _ageController.text =
              patientData['age']?.toString() ?? ''; // แสดงอายุ
          _selectedGender = patientData['gender'] ?? ''; // แสดงเพศ
        });
      }
    } catch (e) {
      print("Error loading patient data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "เกิดข้อผิดพลาดในการโหลดข้อมูล",
            style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
          ),
        ),
      );
    }
  }

  Future<void> _updatePatientData() async {
    try {
      final int? age = int.tryParse(_ageController.text);
      if (age == null) {
        print("กรุณาใส่ค่าอายุที่เป็นตัวเลข");
        return;
      }
      if (_selectedGender.isEmpty) {
        print("กรุณาเลือกเพศ");
        return;
      }

      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .collection('patients')
          .doc(widget.patientId)
          .update({
        'HN': _hnController.text,
        'age': age,
        'gender': _selectedGender,
      });

      // print("ข้อมูลอัปเดตเรียบร้อยแล้ว");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'ข้อมูลผู้ป่วยถูกอัปเดตเรียบร้อยแล้ว',
          style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
        )),
      );

      setState(() {
        _isEdited = false; // รีเซ็ตสถานะการแก้ไขหลังจากบันทึก
      });

      // ใช้ Navigator.pop() เพื่อกลับไปหน้าก่อนหน้า แทนการสร้างหน้าต่างใหม่
      Navigator.pop(context);
    } catch (e) {
      // print(
      //   "เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $e",
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'เกิดข้อผิดพลาดในการอัปเดตข้อมูล: $e',
          style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
        )),
      );
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
                        onPressed: () {
                          _updatePatientData();
                          // Navigator.of(context).pop(true);
                        },
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
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'แก้ไขข้อมูล',
            style: GoogleFonts.prompt(
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("หมายเลข HN", style: promptStyle600_16),
                TextFormField(
                  controller: _hnController,
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.edit, size: 18),
                    filled: true, // เปิดการใช้งานสีพื้นหลัง
                    fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _isEdited = true; // เปลี่ยนสถานะเมื่อมีการแก้ไข
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text("อายุ",
                    style: GoogleFonts.prompt(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                TextFormField(
                  controller: _ageController,
                  style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.edit, size: 18),
                    filled: true, // เปิดการใช้งานสีพื้นหลัง
                    fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _isEdited = true; // เปลี่ยนสถานะเมื่อมีการแก้ไข
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text("เพศ",
                    style: GoogleFonts.prompt(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
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
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedGender = 'หญิง';
                            _isEdited = true; // ตั้งค่าเป็นแก้ไขเมื่อเลือกใหม่
                          });
                        },
                        child: Text('หญิง',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400))),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
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
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedGender = 'ชาย';
                            _isEdited = true; // ตั้งค่าเป็นแก้ไขเมื่อเลือกใหม่
                          });
                        },
                        child: Text('ชาย',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400))),
                      ),
                    ),
                  ],
                ),
                if (_genderError) // แสดงข้อความข้อผิดพลาดเมื่อไม่เลือกเพศ
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "กรุณาเลือกเพศ",
                      style: GoogleFonts.prompt(
                          textStyle:
                              const TextStyle(fontSize: 12, color: Colors.red)),
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: const Color(0xFF5A85D9),
                    ),
                    onPressed: _updatePatientData,
                    child: Text(
                      'บันทึก',
                      style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
