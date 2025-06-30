import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String errorMessage = '';

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Login ke Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil data pengguna dari Firestore (dengan email sebagai document ID)
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(email).get();

      if (!userDoc.exists) {
        setState(() {
          errorMessage = 'Data pengguna tidak ditemukan di Firestore.';
        });
        await _auth.signOut(); // Logout jika Firestore tidak lengkap
        return;
      }

      final role = userDoc['role'];
      print('Login berhasil. Role pengguna: $role');

      // Navigasi ke halaman sesuai role
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else if (role == 'user') {
        Navigator.pushReplacementNamed(context, '/user');
      } else {
        setState(() {
          errorMessage = 'Role tidak dikenali.';
        });
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = 'Login gagal: ${e.message}';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Masuk ke Akun Anda", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Login'),
                onPressed: isLoading ? null : loginUser,
              ),
              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Ganti ini dengan navigasi ke halaman pendaftaran jika ada
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
                },
                child: const Text('Belum punya akun? Daftar di sini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
