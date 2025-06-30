import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hama/screens/auth/register_screen.dart';
import 'package:hama/screens/admin/admin_dashboard.dart';
import 'package:hama/screens/user/user_dashboard.dart';
import 'package:hama/screens/admin/admin_manage_booking.dart';
import 'package:hama/screens/user/riwayat_ruangan.dart';
import 'package:hama/screens/admin/add_room_page.dart';
import 'package:hama/screens/admin/daftar_ruangan_page.dart';
import 'package:hama/screens/admin/verifikasi_booking_page.dart';
import 'package:hama/screens/admin/admin_riwayat_page.dart';
import 'package:hama/screens/user/profile_page.dart';
import 'package:hama/screens/admin/admin_status_booking_page.dart';
import 'package:hama/screens/user/form_booking_page.dart';
import 'package:hama/screens/user/user_status_booking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDyoJSScrn9qTQJBsRCrNJS0ZodF0cyZ-c",
          authDomain: "hama-c9102.firebaseapp.com",
          projectId: "hama-c9102",
          storageBucket: "hama-c9102.appspot.com",
          messagingSenderId: "755423090844",
          appId: "1:755423090844:web:afc27ef7bb9f8e25543559",
          measurementId: "G-65CC9H8T2J",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Gagal inisialisasi Firebase:\n$e',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Hama',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF9F4FC),
        inputDecorationTheme: const InputDecorationTheme(
          border: UnderlineInputBorder(),
          labelStyle: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/user': (context) => const UserDashboard(),
        '/booking': (context) => const FormBookingPage(),
        '/status-booking': (context) => const UserStatusBookingPage(),
        '/kelola-booking': (context) => const AdminManageBookingPage(),
        '/riwayat': (context) => const RiwayatRuangan(),
        '/tambah-ruangan': (context) => const AddRoomPage(),
        '/daftar-ruangan': (context) => const DaftarRuanganPage(),
        '/verifikasi-booking': (context) => const VerifikasiBookingPage(),
        '/admin-riwayat': (context) => const AdminRiwayatPage(),
        '/profile': (context) => const ProfilePage(),
        '/user-status': (context) => const UserStatusBookingPage(),
        '/admin-status': (context) => const AdminStatusBookingPage(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email dan password tidak boleh kosong');
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userDoc = await _firestore.collection('users').doc(email).get();

      if (!userDoc.exists) {
        _showError('Data pengguna tidak ditemukan.');
        return;
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final role = data['role'];

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/user');
      } else {
        _showError('Peran tidak valid.');
      }
    } on FirebaseAuthException catch (e) {
      _showError('Login gagal: ${e.message}');
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Masuk ke Akun Anda', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: login,
              icon: const Icon(Icons.login),
              label: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Belum punya akun? Daftar di sini'),
            ),
          ],
        ),
      ),
    );
  }
}
