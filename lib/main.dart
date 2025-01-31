import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newwieproject/screenUser/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // บังคับให้แอปทำงานในโหมดแนวตั้ง (portrait)
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    // เริ่มการเชื่อมต่อ Firebase
    try {
      await Firebase.initializeApp();
      runApp(const MyApp());
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการเชื่อมต่อ Firebase แสดง UI สำรอง
      runApp(const FirebaseErrorApp());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Angle Check',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Login(),
      // home: Scaffold(
      //   appBar: AppBar(title: Text("Firebase Setup Complete")),
      //   body: Center(child: Text("Welcome to Firebase!")),
      // ),
    );
  }
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Initialization Error")),
        body: const Center(
          child: Text(
            "Failed to initialize Firebase. Please try again later.",
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
