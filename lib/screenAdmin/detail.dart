import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:newwieproject/screenUser/newsetting.dart';

class DoctorDetailPage extends StatefulWidget {
  final String name;
  final String surname;
  final String email;
  final String password;
  final String doctorId;
  final String Adminuid;
  // final Map<String, dynamic> data;

  const DoctorDetailPage({
    super.key,
    required this.name,
    required this.surname,
    required this.email,
    required this.password,
    required this.doctorId,
    required this.Adminuid,
  });

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _EmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.Adminuid)
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        Map<String, dynamic> doctorData =
            doctorDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = doctorData['name']?.toString() ?? '';
          _surnameController.text = doctorData['surname']?.toString() ?? '';
          _EmailController.text = doctorData['email']?.toString() ?? '';
          _passwordController.text = doctorData['password']?.toString() ?? '';

          if (doctorData['name'] == null || doctorData['surname'] == null) {
            print('Data Error: Name or surname is null');
          }
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

  Future<void> _updateDoctorData() async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.Adminuid)
          .collection('doctors')
          .doc(widget.doctorId)
          .update({
        'name': _nameController.text,
        'surname': _surnameController.text,
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
                          _updateDoctorData();
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
          false; // คืนค่าผลลัพธ์ของการกดปุ่ม
    }
    return true; // ถ้าไม่ได้แก้ไขให้ย้อนกลับ
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // ตรวจสอบการย้อนกลับ
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            '${widget.name} ${widget.surname}',
            style: GoogleFonts.prompt(
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ชื่อ",
                      style: GoogleFonts.prompt(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  TextFormField(
                    controller: _nameController,
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
                    onChanged: (value) {
                      setState(() {
                        _isEdited = true; // เปลี่ยนสถานะเมื่อมีการแก้ไข
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "นามสกุล",
                    style: GoogleFonts.prompt(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  TextFormField(
                    style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    controller: _surnameController,
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.edit, size: 18),
                      filled: true, // เปิดการใช้งานสีพื้นหลัง
                      fillColor: const Color(0xFFF5F5F5), // กำหนดสีพื้นหลัง
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isEdited = true;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "อีเมล",
                    style: GoogleFonts.prompt(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF5F5F5),
                    ),
                    // margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.fromLTRB(20, 3, 5, 3),
                    child: Row(
                      children: [
                        Text(
                          _EmailController.text,
                          style: GoogleFonts.prompt(
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const Spacer(), // เพิ่ม Spacer เพื่อขยายพื้นที่ว่างระหว่าง Text และไอคอน
                        IconButton(
                          onPressed: () {
                            // print('copy');
                            Clipboard.setData(
                                ClipboardData(text: _EmailController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'คัดลอก "อีเมล" ไปยังคลิปบอร์ดแล้ว',
                                  style: GoogleFonts.prompt(fontSize: 12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "รหัสผ่าน",
                    style: GoogleFonts.prompt(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF5F5F5),
                    ),
                    // margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.fromLTRB(20, 3, 5, 3),
                    child: Row(
                      children: [
                        Text(
                          _passwordController.text,
                          style: GoogleFonts.prompt(
                            textStyle: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const Spacer(), // เพิ่ม Spacer เพื่อขยายพื้นที่ว่างระหว่าง Text และไอคอน
                        IconButton(
                          onPressed: () {
                            // print('copy');
                            Clipboard.setData(
                                ClipboardData(text: _passwordController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'คัดลอก "รหัสผ่าน" ไปยังคลิปบอร์ดแล้ว',
                                  style: GoogleFonts.prompt(fontSize: 12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                  ),

                  // ปุ่มบันทึกเมื่อแก้ไขข้อมูล
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isEdited
                        ? _updateDoctorData
                        : null, // กดได้เมื่อ _isEdited เป็น true
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      backgroundColor: const Color(0xFF5A85D9),
                    ),
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
      ),
    );
  }
}
