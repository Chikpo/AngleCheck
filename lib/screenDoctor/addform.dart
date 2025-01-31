import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenDoctor/home.dart';
// import 'package:newwieproject/screenUser/register.dart';

final TextStyle promptStyle6 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
);

final TextStyle promptStylebold_18 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
);

final TextStyle promptStyle3 = GoogleFonts.prompt(
  textStyle: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
);

class AddForm extends StatefulWidget {
  const AddForm({super.key});

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hnController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _selectedGender;
  bool _genderError = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid; // Correctly getting the UID

  String? _validateHN(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่ HN';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณาใส่อายุ';
    }
    if (int.tryParse(value) == null) {
      return 'กรุณาใส่อายุที่ถูกต้อง';
    }
    return null;
  }

  Future<void> _addPatient() async {
    setState(() {
      _genderError = _selectedGender == null;
    });

    if (_formKey.currentState!.validate() && _selectedGender != null) {
      String HN = _hnController.text;
      int age = int.parse(_ageController.text);
      String gender = _selectedGender!;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .collection('patients')
            .where('HN', isEqualTo: HN)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Navigator.pop(context); // ปิดโปรเกรส

          // แสดง SnackBar ว่า HN ซ้ำ
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
              'หมายเลข HN นี้ถูกใช้ไปแล้ว',
              style:
                  GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
            )),
          );
          return;
        }

        // Adding the patient data to Firestore
        await FirebaseFirestore.instance
            .collection('user')
            .doc(uid)
            .collection('patients')
            .add({
          'HN': HN,
          'age': age,
          'gender': gender,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'เพิ่มผู้ป่วยเรียบร้อยแล้ว',
            style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
          )),
        );

        Navigator.pop(context); // Close the progress dialog

        // Redirect to the Home page
        // Navigator.pushReplacement(context, MaterialPageRoute(
        //   builder: (context) {
        //     return const DoctorHome();
        //   },
        // )
        // );

        _hnController.clear();
        _ageController.clear();
      } on FirebaseException catch (e) {
        Navigator.pop(context); // Close the progress dialog
        String message = 'เกิดข้อผิดพลาดในการเพิ่มผู้ป่วย';

        // Handle specific Firebase errors if needed
        if (e.code == 'HN-already-in-use') {
          message = 'หมายเลข HN นี้ถูกใช้ไปแล้ว';
        } else if (e.code == 'Incomplete-HN') {
          message = 'กรอกหมายเลข HN ไม่ครบ';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        Navigator.pop(context); // Close the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'เกิดข้อผิดพลาด: ${e.toString()}',
            style: GoogleFonts.prompt(textStyle: const TextStyle(fontSize: 12)),
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("เพิ่มผู้ป่วย"),
        titleTextStyle: GoogleFonts.prompt(
            textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("หมายเลข HN", style: promptStyle3),
              TextFormField(
                controller: _hnController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0), width: 2.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFF5A85D9), width: 2.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.5),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    errorStyle: GoogleFonts.prompt(
                        textStyle:
                            const TextStyle(fontSize: 12, color: Colors.red))),
                style: promptStyle6,
                validator: _validateHN,
              ),
              Text("อายุ", style: promptStyle3),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFFE0E0E0), width: 2.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          color: Color(0xFF5A85D9), width: 2.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.5),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    errorStyle: GoogleFonts.prompt(
                        textStyle:
                            const TextStyle(fontSize: 12, color: Colors.red))),
                style: promptStyle6,
                validator: _validateAge,
              ),
              const SizedBox(height: 20),
              Text("เพศ", style: promptStyle3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        // padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedGender = 'หญิง';
                          _genderError = false;
                        });
                      },
                      child: Text('หญิง',
                          style: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400))),
                    ),
                  ),
                  const SizedBox(width: 20),
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
                        // padding: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedGender = 'ชาย';
                          _genderError = false;
                        });
                      },
                      child: Text('ชาย',
                          style: GoogleFonts.prompt(
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400))),
                    ),
                  ),
                ],
              ),
              if (_genderError)
                Text('กรุณาเลือกเพศ',
                    style: GoogleFonts.prompt(
                        textStyle:
                            const TextStyle(color: Colors.red, fontSize: 12))),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    backgroundColor: const Color(0xFF5A85D9),
                  ),
                  onPressed: _addPatient,
                  child: Text(
                    'เพิ่มผู้ป่วย',
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
    );
  }
}
