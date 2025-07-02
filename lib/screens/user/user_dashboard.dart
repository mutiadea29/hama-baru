import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Stream<QuerySnapshot> _getBookingData(String type, String uid) {
    final ref = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid);

    if (type == 'riwayat') {
      return ref.where('status', isEqualTo: 'done').snapshots();
    } else if (type == 'status') {
      return ref.where('status', whereIn: ['pending', 'confirmed']).snapshots();
    } else {
      return ref.snapshots(); // semua booking
    }
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String type,
    required String uid,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getBookingData(type, uid),
      builder: (context, snapshot) {
        int count = snapshot.data?.docs.length ?? 0;

        return Container(
          constraints: const BoxConstraints(maxHeight: 120),
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count data',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengguna'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Pengguna'),
              accountEmail: Text(user?.email ?? 'Email tidak tersedia'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Booking Ruangan'),
              onTap: () => Navigator.pushNamed(context, '/booking'),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Status Booking'),
              onTap: () => Navigator.pushNamed(context, '/user-status'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Booking'),
              onTap: () => Navigator.pushNamed(context, '/riwayat'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Hai, ${user?.email ?? 'Pengguna'} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Berikut ringkasan data booking kamu:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                _buildInfoCard(
                  title: 'Booking Ruangan',
                  icon: Icons.book,
                  color: Colors.teal,
                  type: 'booking',
                  uid: uid,
                ),
                _buildInfoCard(
                  title: 'Status Booking',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  type: 'status',
                  uid: uid,
                ),
                _buildInfoCard(
                  title: 'Riwayat Booking',
                  icon: Icons.history,
                  color: Colors.blue,
                  type: 'riwayat',
                  uid: uid,
                ),
                _buildInfoCard(
                  title: 'Profil Saya',
                  icon: Icons.person,
                  color: Colors.purple,
                  type: 'profile',
                  uid: uid,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
