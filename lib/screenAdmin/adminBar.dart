import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newwieproject/screenAdmin/addDoctor.dart';
import 'package:newwieproject/screenAdmin/home.dart';
import 'package:newwieproject/screenDoctor/history.dart';
import 'package:newwieproject/screenUser/login.dart';
import 'package:newwieproject/screenUser/newsetting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBar extends StatefulWidget {
  final String Adminuid;

  const AdminBar({super.key, required this.Adminuid});
  @override
  State<AdminBar> createState() => _AdminBarState();
}

class _AdminBarState extends State<AdminBar> {
  int _currentIndex = 0;

  // Create a list of the screens for the navigation
  // ลบ const ออกเนื่องจากต้องการให้สามารถแก้ไขค่าได้
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    // สร้างหน้าจอทั้งหมดที่ต้องการแสดง
    screens = [
      AdminHome(Adminuid: widget.Adminuid),
      AdminAddDoctor(Adminuid: widget.Adminuid)
    ];
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
              child: Text('ออกจากระบบของคุณใช่ไหม?', style: promptStyle600_16)),
          // content:
          //     Text('ออกจากระบบบัญชีของคุณใช่ไหม?', style: promptStyleNormal_15),
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
                        side: const BorderSide(color: Colors.black, width: 2.5),
                        minimumSize: const Size(80, 45)),
                    child: Text('ยกเลิก',
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _signOut();
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF5A85D9),
                        minimumSize: const Size(100, 45),
                        side: const BorderSide(
                            color: Color(0xFF5A85D9), width: 2.5)),
                    child: Text('ออกจากระบบ',
                        style: GoogleFonts.prompt(
                            textStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    // เมื่อออกจากระบบเสร็จแล้ว จะไปยังหน้า Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        iconSize: 25,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xFF5A85D9),
        unselectedItemColor: Colors.grey, // Set color for unselected items
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add Doctor",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.logout_outlined),
            label: "Logout",
          ),
        ],
        onTap: (newIndex) {
          setState(() {
            if (newIndex == 2) {
              // หากคลิกที่ Logout ให้แสดง dialog
              _showSignOutDialog();
            } else {
              _currentIndex = newIndex;
            }
          });
        },
      ),
    );
  }
}
