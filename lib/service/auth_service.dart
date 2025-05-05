import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login menggunakan Firebase Authentication dan verifikasi data user di Firestore
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // Login via Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika berhasil login, cari data user di Firestore berdasarkan email
      // (karena ID dokumen dan UID tidak sama)
      QuerySnapshot userDocs =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userDocs.docs.isEmpty) {
        print("User data not found in Firestore");
        return null;
      }

      // Ambil data user
      Map<String, dynamic> userData =
          userDocs.docs.first.data() as Map<String, dynamic>;

      // Periksa status user
      if (userData['status'] != 'active') {
        print("User is not active");
        await _auth.signOut(); // Logout jika user tidak aktif
        return null;
      }

      // Tambahkan uid ke data untuk referensi
      userData['uid'] = userCredential.user?.uid;

      return userData;
    } on FirebaseAuthException catch (e) {
      print("Login error: ${e.message}");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    print("User logged out");
  }

  // Mendapatkan ID user saat ini
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Mengambil data user dari Firestore berdasarkan email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      QuerySnapshot userDocs =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userDocs.docs.isEmpty) {
        return null;
      }

      return userDocs.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      print("Get user by email error: $e");
      return null;
    }
  }

  // Mengambil role dari firestore
  Future<String?> getUserRole(String email) async {
    try {
      Map<String, dynamic>? userData = await getUserByEmail(email);
      return userData?['role'];
    } catch (e) {
      print("Get user role error: $e");
      return null;
    }
  }

  // Mengelola role user
  Future<void> manageRole(String email, String newRole) async {
    try {
      QuerySnapshot userDocs =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (userDocs.docs.isNotEmpty) {
        await userDocs.docs.first.reference.update({'role': newRole});
      }
    } catch (e) {
      print("Manage role error: $e");
    }
  }

  // Hash password menggunakan BCrypt (untuk keamanan)
  String hashPassword(String password) {
    String salt = BCrypt.gensalt();
    String hashedPassword = BCrypt.hashpw(password, salt);
    return hashedPassword;
  }

  // Verifikasi password (fungsi ini tidak digunakan untuk login utama)
  bool verivyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword);
  }

  // Untuk membuat user baru dengan konsistensi antara Auth dan Firestore
  Future<User?> createUser(
    String email,
    String password,
    String role,
    String username,
  ) async {
    try {
      // Buat user di Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Hash password untuk disimpan di Firestore
      String hashedPassword = hashPassword(password);

      // Simpan data user di Firestore dengan ID yang sama dengan UID
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'password': hashedPassword,
        'role': role,
        'status': 'active',
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      print("Create user error: $e");
      return null;
    }
  }

  bool verifyPassword(String password, String hashedPassword) {
    return BCrypt.checkpw(password, hashedPassword); // Verify password
  }
}
