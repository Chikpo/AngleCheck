import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenDoctor/history.dart';

import 'package:newwieproject/screenUser/newsetting.dart';

class Item extends StatefulWidget {
  const Item({super.key});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  List<Map<String, dynamic>> _patientDataList = [];
  List<Map<String, dynamic>> _filteredPatientDataList = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isDeletingMode = false; // ตัวแปรสำหรับโหมดลบ
  final List<String> _selectedItems = []; // รายการที่ถูกเลือก
  // String patientId = doc.id; // ใช้ docId สำหรับการเลือก

  @override
  void initState() {
    super.initState();
    _getPatientData();
  }

  Future<void> _getPatientData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        QuerySnapshot patientsSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .collection('patients')
            .where('isHidden', isEqualTo: false)
            .get();

        if (patientsSnapshot.docs.isNotEmpty) {
          setState(() {
            _patientDataList = patientsSnapshot.docs.map((doc) {
              // เก็บ id และข้อมูลอื่น ๆ
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // เพิ่ม id ลงในข้อมูล
              return data;
            }).toList();
            _filteredPatientDataList =
                _patientDataList; // ตั้งค่าเริ่มต้นให้กรองทุกตัว
          });
        }
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }

  void _filterPatients() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      if (searchText.isEmpty) {
        // ถ้าช่องค้นหาว่าง ให้แสดงรายการทั้งหมด
        _filteredPatientDataList = _patientDataList;
      } else {
        // ถ้าช่องค้นหาไม่ว่าง ให้กรองตาม HN ที่ขึ้นต้นด้วย searchText
        _filteredPatientDataList = _patientDataList.where((patient) {
          String hn = patient['HN'].toString().toLowerCase();
          return hn.startsWith(searchText); // ใช้ startsWith แทน contains
        }).toList();
      }
    });
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
    User? user =
        FirebaseAuth.instance.currentUser; // เพิ่มการเรียก uid ของผู้ใช้
    if (user != null) {
      String uid = user.uid;

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
                          for (String patientId in _selectedItems) {
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(uid)
                                .collection('patients')
                                .doc(patientId)
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
                          _getPatientData(); // อัปเดตรายการหลังจากลบแล้ว
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
        title: const Text("รายการ HN ของผู้ป่วย"),
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
                  onChanged: (value) {
                    _filterPatients(); // เรียกฟังก์ชันกรองข้อมูลทุกครั้งที่พิมพ์ข้อความ
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF939393),
                      size: 18,
                    ),
                    hintText: 'ค้นหาหมายเลข HN',
                    hintStyle: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF939393))),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFF5A85D9), width: 2.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFFF1F1F1)),
                    ),
                  ),
                  style: GoogleFonts.prompt(
                      textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredPatientDataList.isEmpty
                  ? Center(
                      child: Text(
                        'ยังไม่มีผู้ป่วย',
                        style: GoogleFonts.prompt(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredPatientDataList.length,
                      itemBuilder: (context, index) {
                        final patientData = _filteredPatientDataList[index];
                        String patientId = patientData[
                            'id']; // ใช้ patientData['id'] แทน doc.id
                        return Column(
                          children: [
                            FilledButton(
                              onPressed: () {
                                if (_isDeletingMode) {
                                  _toggleSelection(patientId);
                                } else {
                                  if (patientData.containsKey('HN') &&
                                      patientData.containsKey('id')) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PatientDetailStateful(
                                          hn: patientData['HN'],
                                          patientId: patientData['id'],
                                        ),
                                      ),
                                    );
                                  } else {
                                    print(
                                        'Error: patientData is missing HN or id');
                                  }
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: _isDeletingMode &&
                                          _selectedItems.contains(patientId)
                                      ? Colors.red
                                      : const Color(0xFF5A85D9),
                                  width: 2.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        patientData['gender'] == "ชาย"
                                            ? 'assets/images/pic7.png'
                                            : 'assets/images/pic6.png',
                                        width: 40,
                                        height: 40,
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        "${patientData['HN']}",
                                        style: GoogleFonts.prompt(
                                            textStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
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
                          size: 24,
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
