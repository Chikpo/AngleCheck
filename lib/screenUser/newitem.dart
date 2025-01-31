import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:newwieproject/screenUser/newDetail.dart';

final TextStyle promptStyleNor_14 = GoogleFonts.prompt(
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal));

final TextStyle promptStyle600_16 = GoogleFonts.prompt(
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));

final TextStyle promptStyle600_14 = GoogleFonts.prompt(
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));

final TextStyle promptStyle600_12 = GoogleFonts.prompt(
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600));

class UserItem extends StatefulWidget {
  const UserItem({super.key});

  @override
  State<UserItem> createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  bool _isDeletingMode = false; // ตัวแปรสำหรับโหมดลบ
  final List<String> _selectedItems = []; // รายการที่ถูกเลือก
  late final String _userId;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  Stream<QuerySnapshot> _getUserData() {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(_userId)
        .collection('photo')
        .where('isHidden', isEqualTo: false) // กรองเฉพาะภาพที่ไม่ถูกซ่อน
        .orderBy('timestamp', descending: true) // เรียงตามเวลาล่าสุด
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
                // crossAxisAlignment: CrossAxisAlignment.center,
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
                    // onPressed: () {
                    //   // ดำเนินการลบรายการที่เลือก
                    //   for (String photoId in _selectedItems) {
                    //     FirebaseFirestore.instance
                    //         .collection('user')
                    //         .doc(_userId)
                    //         .collection('photo')
                    //         .doc(photoId)
                    //         .update({'isHidden': true});
                    //   }
                    //   Navigator.of(context).pop();
                    //   _toggleDeleteMode(); // เปลี่ยนกลับไปโหมดปกติ
                    // },
                    onPressed: () async {
                      try {
                        // ดำเนินการลบรายการที่เลือก
                        for (String photoId in _selectedItems) {
                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(_userId)
                              .collection('photo')
                              .doc(photoId)
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
                        padding: const EdgeInsets.all(10),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("ประวัติย้อนหลัง"),
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
                size: 24,
                color: _isDeletingMode ? Colors.white : Colors.black,
              ),
              onPressed: _toggleDeleteMode,
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
                            fontSize: 12, fontWeight: FontWeight.normal))),
                SizedBox(width: 5),
                Icon(Icons.circle,
                    color: Colors.black, // สีของไอคอน
                    size: 16),
                SizedBox(width: 5), // เว้นระยะห่างระหว่างไอคอนและข้อความ
                Text("ค่าไม่ปกติ", // ข้อความที่แสดง
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal)))
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getUserData(),
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

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      String photoId = doc.id; // ใช้ docId สำหรับการเลือก
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
                                _toggleSelection(photoId);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserDetail(
                                              photoUrl: photoUrl,
                                              cva: cva,
                                              fsp: fsp,
                                              onlydate: onlydate,
                                              onlytime: onlytime,
                                              formatted: formatted,
                                            )));
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: _isDeletingMode &&
                                        _selectedItems.contains(photoId)
                                    ? Colors.red
                                    : const Color(0xFF5A85D9),
                                width: 2.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.network(photoUrl, width: 80, height: 100),
                                const SizedBox(width: 50),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                            : Colors.grey,
                                        // color: const Color(0xFF5A85D9)
                                      ),
                                      // padding:
                                      //     const EdgeInsets.fromLTRB(20, 5, 20, 5),
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
                                        borderRadius: BorderRadius.circular(30),
                                        color: (doc['fsp'] != null)
                                            ? (doc['fsp'] < 52
                                                ? Colors.orange
                                                : Colors.green)
                                            : Colors.grey,
                                        // color: const Color(0xFF5A85D9)
                                      ),
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
