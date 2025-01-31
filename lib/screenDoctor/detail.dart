import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorDetail extends StatelessWidget {
  final String photoUrl;
  final String cva;
  final String fsp;
  final String onlydate;
  final String onlytime;
  final String formatted;

  const DoctorDetail(
      {super.key,
      required this.photoUrl,
      required this.cva,
      required this.fsp,
      required this.onlydate,
      required this.onlytime,
      required this.formatted});

  @override
  Widget build(BuildContext context) {
    double? cvaValue = double.tryParse(cva);
    double? fspValue = double.tryParse(fsp);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          formatted,
          style: GoogleFonts.prompt(
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
      body: SingleChildScrollView(
        // เพิ่ม SingleChildScrollView ที่นี่
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_outlined,
                      color: Colors.black, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    onlytime,
                    style: GoogleFonts.prompt(
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 25, 30, 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(photoUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(
                          color: (cvaValue != null)
                              ? (cvaValue >= 32 && cvaValue < 43
                                  ? Colors.red
                                  : (cvaValue >= 43 && cvaValue < 47
                                      ? Colors.orange
                                      : (cvaValue >= 47 && cvaValue <= 50
                                          ? Colors.yellow
                                          : (cvaValue > 50
                                              ? Colors.black
                                              : Colors.green))))
                              : Colors.grey, // กรณีที่ cva ไม่มีค่า
                          width: 2.5),
                    ),
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text("CVA",
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black))),
                        SizedBox(height: 5),
                        Text("$cva°",
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black))),
                      ],
                    )),
                SizedBox(width: 5),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      border: Border.all(
                          color: (fspValue != null)
                              ? (fspValue < 52 ? Colors.orange : Colors.green)
                              : Colors.grey, // กรณีที่ cva ไม่มีค่า
                          width: 2.5),
                    ),
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                    margin: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Text("FSA",
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black))),
                        SizedBox(height: 5),
                        Text("$fsp°",
                            style: GoogleFonts.prompt(
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black))),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
