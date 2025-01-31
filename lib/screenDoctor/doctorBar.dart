import 'package:flutter/material.dart';
import 'package:newwieproject/screenDoctor/addform.dart';
import 'package:newwieproject/screenDoctor/home.dart';
import 'package:newwieproject/screenDoctor/item.dart';
import 'package:newwieproject/screenDoctor/setting.dart';

class DoctorBar extends StatefulWidget {
  const DoctorBar({super.key});

  @override
  State<DoctorBar> createState() => _DoctorBarState();
}

class _DoctorBarState extends State<DoctorBar> {
  int _currentIndex = 0;

  // Create a list of the screens for the navigation
  final List<Widget> screens = const [
    DoctorHome(), // Your home screen widget
    Item(), // Your item list screen widget
    AddForm(), // Your add patient form widget
    DoctorSetting(), // Your settings screen widget
  ];

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
          BottomNavigationBarItem(
            icon: Icon(_currentIndex == 1
                ? Icons.view_list_outlined
                : Icons.list_rounded),
            label: "List",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add Patient",
          ),
          BottomNavigationBarItem(
            icon: Icon(
                _currentIndex == 3 ? Icons.settings : Icons.settings_outlined),
            label: "Setting",
          ),
        ],
        onTap: (newIndex) {
          setState(() {
            _currentIndex = newIndex; // Update the current index
          });
        },
      ),
    );
  }
}
