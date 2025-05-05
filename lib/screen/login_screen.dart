import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:laundryapp/screen/dashboard_screen.dart';
import 'package:laundryapp/screen/register_screen.dart';
import 'package:laundryapp/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;

  // Method untuk melakukan login
  Future<void> _performLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Validasi field
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email harus diisi terlbeih dahulu!')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password harus diisi terlbeih dahulu!')),
      );
      return;
    }

    // Proses login
    Map<String, dynamic>? userData = await _authService.login(email, password);

    if (userData != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login berhasil!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => DashboardScreen(
                role: userData['role'],
                userId: userData['uid'],
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Email atau password salah!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _performLogin, // Panggil method _performLogin
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Register',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
