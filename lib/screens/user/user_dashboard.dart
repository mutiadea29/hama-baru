import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Dashboard Pengguna'),
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hai, ${user?.email ?? 'Pengguna'} 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selamat datang di aplikasi peminjaman ruangan!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildDashboardCard(
                    icon: Icons.meeting_room,
                    label: 'Booking Ruangan',
                    count: '12',
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/booking'),
                  ),
                  _buildDashboardCard(
                    icon: Icons.pending_actions,
                    label: 'Status Booking',
                    count: '3',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/user-status'),
                  ),
                  _buildDashboardCard(
                    icon: Icons.history,
                    label: 'Riwayat Booking',
                    count: '25',
                    color: Colors.indigo,
                    onTap: () => Navigator.pushNamed(context, '/riwayat'),
                  ),
                  _buildDashboardCard(
                    icon: Icons.account_circle,
                    label: 'Profil',
                    count: '',
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Lihat Detail",
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}