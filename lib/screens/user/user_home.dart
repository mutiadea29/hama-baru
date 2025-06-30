import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hama/screens/user/profile_page.dart';
import 'package:hama/screens/user/bookingan_page.dart';
import 'package:hama/screens/user/riwayat_ruangan.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Dashboard')),
      drawer: const DrawerWidget(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Selamat datang, User!', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/booking');
            },
            icon: const Icon(Icons.add),
            label: const Text('Booking Ruangan'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/riwayat');
            },
            icon: const Icon(Icons.history),
            label: const Text('Riwayat Booking'),
          ),
        ],
      ),
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'Menu User',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Booking Ruangan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/booking');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Booking'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/riwayat');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
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
