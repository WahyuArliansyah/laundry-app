import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laundryapp/firebase_options.dart';
import 'package:laundryapp/screen/dashboard_screen.dart';
import 'package:laundryapp/screen/login_screen.dart';
import 'package:laundryapp/screen/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userId = prefs.getString('userId') ?? '';

    if (isLoggedIn && userId.isNotEmpty) {
      // Ambil data user dari Firestore
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return DashboardScreen(role: userData['role'], userId: userId);
      }
    }
    return LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else if (snapshot.hasData) {
          return MaterialApp(
            title: 'Laundry Store',
            debugShowCheckedModeBanner: false,
            home: snapshot.data,
            routes: {'register': (context) => RegisterScreen()},
          );
        } else {
          return MaterialApp(
            title: 'Laundry Store',
            debugShowCheckedModeBanner: false,
            home: LoginScreen(),
            routes: {'register': (context) => RegisterScreen()},
          );
        }
      },
    );
  }
}
