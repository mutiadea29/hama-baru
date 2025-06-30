import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hama/screens/user/profile_page.dart'; // ✅ Pastikan path ini benar sesuai struktur project kamu

class DrawerWidget extends StatelessWidget {
  final String role;

  const DrawerWidget({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Text(
              'Menu ${role[0].toUpperCase()}${role.substring(1).toLowerCase()}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const ListTile(leading: Icon(Icons.person), title: Text('Profil')),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const Divider(),
          const ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
          ListTile(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
