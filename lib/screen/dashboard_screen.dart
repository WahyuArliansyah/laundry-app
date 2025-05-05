import 'package:laundryapp/screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:laundryapp/service/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  final String role;
  final String userId;
  final AuthService _authService = AuthService();

  DashboardScreen({required this.role, required this.userId, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await widget._authService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text('Role: ${widget.role}'),
            Text('User ID: ${widget.userId}'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
