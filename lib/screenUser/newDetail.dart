import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenUser/angle.dart';
import 'package:newwieproject/screenUser/newExer.dart';
import 'package:newwieproject/screenUser/newExerFSA.dart';

class UserDetail extends StatelessWidget {
  final String photoUrl;
  final String cva;
  final String fsp;
  final String onlydate;
  final String onlytime;
  final String formatted;

  const UserDetail(
      {super.key,
      required this.photoUrl,
      required this.cva,
      required this.fsp,
      required this.onlydate,
      required this.onlytime,
      required this.formatted});

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Craniovertebral Angle (CVA)",
                  style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "คือมุมที่ใช้ประเมินการยื่นไปข้างหน้าของศีรษะ หากมีค่าน้อยกว่าค่าปกติจะบ่งชี้ถึงการมีภาวะศีรษะยื่นไปด้านหน้า หรือ Forward Head Posture (FHP)",
                  style: GoogleFonts.sarabun(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Forward Shoulder Angle (FSA)",
                  style: GoogleFonts.prompt(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "คือมุมที่ใช้ประเมินการงุ้มของข้อไหล่ หากได้ค่าที่น้อยกว่าค่าปกติจะบ่งชี้ถึงการมีภาวะไหล่งุ้ม (Round shoulder posture)",
                  style: GoogleFonts.sarabun(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     child: Text('ปิด'),
          //   ),
          // ],
        );
      },
    );
  }

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
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        //     width: 40,
        //     height: 40,
        //     child: IconButton(
        //       icon: Icon(Icons.info_outline,size: 22),
        //       onPressed: () => _showInfoDialog(context),
        //     ),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                //   child: Container(
                //       width: double.infinity,
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(30),
                //         color: const Color(0xFFF1F1F1),
                //       ),
                //       padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                //       margin: const EdgeInsets.all(5),
                //       child: Padding(
                //           padding: const EdgeInsets.all(10),
                //           child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text("Craniovertebral Angle (CVA)",
                //                     style: GoogleFonts.prompt(
                //                         textStyle: const TextStyle(
                //                             fontSize: 16,
                //                             fontWeight: FontWeight.bold))),
                //                 Text("คือมุมที่ใช้ประเมินการยื่นไปข้างหน้าของศีรษะ หากมีค่าน้อยกว่าค่าปกติจะบ่งชี้ถึงการมีภาวะศีรษะยื่นไปด้านหน้า หรือ Forward Head Posture (FHP)",
                //                     style: GoogleFonts.sarabun(
                //                         textStyle: const TextStyle(
                //                             fontSize: 14,
                //                             fontWeight: FontWeight.normal))),
                //                 SizedBox(width: 5),
                //                 Text("Forward Shoulder Angle (FSA)",
                //                     style: GoogleFonts.prompt(
                //                         textStyle: const TextStyle(
                //                             fontSize: 16,
                //                             fontWeight: FontWeight.bold))),
                //                 Text("คือมุมที่ใช้ประเมินการงุ้มของข้อไหล่ หากได้ค่าที่น้อยกว่าค่าปกติจะบ่งชี้ถึงการมีภาวะไหล่งุ้ม (Round shoulder posture)",
                //                     style: GoogleFonts.sarabun(
                //                         textStyle: const TextStyle(
                //                             fontSize: 14,
                //                             fontWeight: FontWeight.normal))),
                //               ]
                //           )
                //       )
                //   ),
                // ),
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
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      ),
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
                                  ? (fspValue < 52
                                      ? Colors.orange
                                      : Colors.green)
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
                                        fontWeight: FontWeight.w400,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xFFF1F1F1),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          margin: const EdgeInsets.all(5),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Craniovertebral Angle (CVA)",
                                        style: GoogleFonts.prompt(
                                            textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold))),
                                    Text(
                                        "คือมุมที่ใช้ประเมินการยื่นไปข้างหน้าของศีรษะ หากมีค่าน้อยกว่าค่าปกติจะบ่งชี้ถึงการมีภาวะศีรษะยื่นไปด้านหน้า หรือ Forward Head Posture (FHP)",
                                        style: GoogleFonts.sarabun(
                                            textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.normal))),
                                    SizedBox(width: 5),
                                    Text("Forward Shoulder Angle (FSA)",
                                        style: GoogleFonts.prompt(
                                            textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold))),
                                    Text(
                                        "คือมุมที่ใช้ประเมินการงุ้มของข้อไหล่ หากได้ค่าที่น้อยกว่าค่าปกติจะบ่งชี้ถึงการมีภาวะไหล่งุ้ม (Round shoulder posture)",
                                        style: GoogleFonts.sarabun(
                                            textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.normal))),
                                  ]))),
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xFFF1F1F1),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          margin: const EdgeInsets.all(5),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(getCvaMessage(cvaValue ?? 0.0),
                                        style: GoogleFonts.prompt(
                                            textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold))),
                                    Text(getCvaDetail(cvaValue ?? 0.0),
                                        style: GoogleFonts.sarabun(
                                            textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.normal))),
                                    SizedBox(height: 10),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UserExer()));
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF5A85D9),
                                        // padding: const EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          // side: BorderSide(color: const Color(0xFF5A85D9))
                                        ),
                                        minimumSize: const Size.fromHeight(40),
                                      ),
                                      child: Text('วิดีโอการกายภาพคอ',
                                          style: GoogleFonts.prompt(
                                              textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    )
                                  ]))),
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color(0xFFF1F1F1),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          margin: const EdgeInsets.all(5),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(getFspMessage(fspValue ?? 0.0),
                                    style: GoogleFonts.prompt(
                                        textStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))),
                                Text(getFspDetail(fspValue ?? 0.0),
                                    style: GoogleFonts.sarabun(
                                        textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal))),
                                SizedBox(height: 10),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UserExerFSA()));
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF5A85D9),
                                    // padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      // side: BorderSide(color: const Color(0xFF5A85D9))
                                    ),
                                    minimumSize: const Size.fromHeight(40),
                                  ),
                                  child: Text('วิดีโอการกายภาพไหล่',
                                      style: GoogleFonts.prompt(
                                          textStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600))),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(30, 15, 30, 10),
          //     child: FilledButton(
          //       onPressed: () {
          //         Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => UserExer()));
          //       },
          //       style: FilledButton.styleFrom(
          //         backgroundColor: const Color(0xFF5A85D9),
          //         // padding: const EdgeInsets.symmetric(vertical: 15),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //           // side: BorderSide(color: const Color(0xFF5A85D9))
          //         ),
          //         minimumSize: const Size.fromHeight(40),
          //       ),
          //       child: Text('วิดีโอการกายภาพ',
          //           style: GoogleFonts.prompt(
          //               textStyle: const TextStyle(
          //                   fontSize: 16, fontWeight: FontWeight.w600))),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
