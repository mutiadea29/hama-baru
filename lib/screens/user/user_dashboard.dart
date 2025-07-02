import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final User? user = FirebaseAuth.instance.currentUser;

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Stream<QuerySnapshot> _getBookingData(String type) {
    final bookingsRef = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user?.uid);

    if (type == 'riwayat') {
      return bookingsRef.where('status', isEqualTo: 'done').snapshots();
    } else if (type == 'status') {
      return bookingsRef.where('status', whereIn: ['pending', 'confirmed']).snapshots();
    } else {
      return bookingsRef.snapshots(); // Semua booking
    }
  }

  Widget _buildBookingList(String title, String type, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: _getBookingData(type),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("Tidak ada data tersedia.");
            }

            final bookings = snapshot.data!.docs;

            return Column(
              children: bookings.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.meeting_room),
                    title: Text(data['roomName'] ?? '-'),
                    subtitle: Text("Tanggal: ${data['date'] ?? '-'}\nStatus: ${data['status'] ?? '-'}"),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengguna'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Pengguna'),
              accountEmail: Text(user?.email ?? 'Email tidak tersedia'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, color: Colors.green, size: 40),
              ),
              decoration: const BoxDecoration(color: Colors.green),
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
              'Berikut data booking ruangan kamu:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildBookingList("📌 Booking Aktif", "booking", Colors.teal),
            _buildBookingList("⏳ Status Booking", "status", Colors.orange),
            _buildBookingList("📁 Riwayat Booking", "riwayat", Colors.blue),
          ],
        ),
      ),
    );
  }
}
