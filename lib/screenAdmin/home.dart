import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenAdmin/detail.dart';
import 'package:newwieproject/screenDoctor/history.dart';
import 'package:newwieproject/screenUser/newsetting.dart';

class AdminHome extends StatefulWidget {
  final String Adminuid;

  const AdminHome({super.key, required this.Adminuid});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<Map<String, dynamic>> _doctorDataList = []; // รายการข้อมูลแพทย์ทั้งหมด
  List<Map<String, dynamic>> _filteredDoctorDataList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isDeletingMode = false; // ตัวแปรสำหรับโหมดลบ
  final List<String> _selectedItems = []; // รายการที่ถูกเลือก

  @override
  void initState() {
    super.initState();
    _getDoctorData();
  }

  Future<void> _getDoctorData() async {
    try {
      QuerySnapshot doctorsSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.Adminuid)
          .collection('doctors')
          .where('isHidden', isEqualTo: false)
          .get();

      if (doctorsSnapshot.docs.isNotEmpty) {
        setState(() {
          _doctorDataList = doctorsSnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // เพิ่ม id ลงในข้อมูล
            return data;
          }).toList();
          _filteredDoctorDataList = _doctorDataList;
        });
      }
    } catch (e) {
      print('Error fetching doctor data: $e');
    }
  }

  void _filterDoctors() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      if (searchText.isEmpty) {
        _filteredDoctorDataList = _doctorDataList;
      } else {
        _filteredDoctorDataList = _doctorDataList.where((doctor) {
          String name = doctor['name'].toString().toLowerCase();
          String surname = doctor['surname'].toString().toLowerCase();

          return name.startsWith(searchText) || surname.startsWith(searchText);
          // กรองชื่อหรือสกุลที่เริ่มต้นด้วย searchText
        }).toList();
      }
    });
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeletingMode = !_isDeletingMode;
      _selectedItems.clear();
    });
  }

  void _toggleSelection(String doctorId) {
    setState(() {
      if (_selectedItems.contains(doctorId)) {
        _selectedItems.remove(doctorId);
      } else {
        _selectedItems.add(doctorId);
      }
    });
  }

  void _confirmDelete(BuildContext context) {
    User? user =
        FirebaseAuth.instance.currentUser; // เพิ่มการเรียก uid ของผู้ใช้
    if (user != null) {
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
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(10),
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                                color: Colors.black, width: 2.5),
                            minimumSize: const Size(80, 45)),
                        child: Text('ยกเลิก',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)))),
                    const SizedBox(width: 20),
                    OutlinedButton(
                        onPressed: () async {
                          try {
                          for (String doctorId in _selectedItems) {
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(widget.Adminuid)
                                .collection('doctors')
                                .doc(doctorId)
                                .update({'isHidden': true});
                                // .delete(); // ลบเอกสารจาก Firestore ตาม id

                          }

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('ลบข้อมูลสำเร็จ',
                                  style: GoogleFonts.prompt(
                                      textStyle:
                                      const TextStyle(fontSize: 14)))));

                          Navigator.of(context).pop();
                          _toggleDeleteMode(); // เปลี่ยนกลับไปโหมดปกติ
                          _getDoctorData(); // อัปเดตรายการหลังจากลบแล้ว
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
                            padding: const EdgeInsets.all(10),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF5A85D9),
                            side: const BorderSide(
                                color: Color(0xFF5A85D9), width: 2.5),
                            minimumSize: const Size(80, 45)),
                        child: Text('ลบ',
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)))),
                  ],
                ),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("รายการชื่อหมอ"),
        titleTextStyle: GoogleFonts.prompt(
          textStyle: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                Icons.delete,
                size: 22,
                color: _isDeletingMode ? Colors.white : Colors.black,
              ),
              onPressed: _toggleDeleteMode,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: Center(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterDoctors(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF939393), size: 18),
                    hintText: 'ค้นหาชื่อหรือนามสกุล',
                    hintStyle: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF939393))),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDoctorDataList.length,
                itemBuilder: (context, index) {
                  final doctorData = _filteredDoctorDataList[index];
                  final doctorId = doctorData['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton(
                      onPressed: () {
                        if (_isDeletingMode) {
                          _toggleSelection(doctorId);
                        } else {
                          if (doctorData.containsKey('name') &&
                              doctorData.containsKey('id')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailPage(
                                    name: doctorData['name'],
                                    surname: doctorData['surname'],
                                    email: doctorData['email'],
                                    password: doctorData['password'],
                                    doctorId: doctorData['id'],
                                    Adminuid: widget.Adminuid
                                    //// ตรวจสอบว่าค่านี้ไม่เป็น null
                                    ),
                              ),
                            );
                          } else {
                            print('Error: doctorData is missing name or id');
                          }
                        }
                        print('doctorData: $doctorData');
                        print(widget.Adminuid);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: _isDeletingMode &&
                                  _selectedItems.contains(doctorId)
                              ? Colors.red
                              : const Color(0xFF5A85D9),
                          width: 2.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        // minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset('assets/images/pic1.png',
                              width: 40, height: 40),
                          const SizedBox(width: 20),
                          Text("${doctorData['name']} ${doctorData['surname']}",
                              style: GoogleFonts.prompt(
                                  textStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ),
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
