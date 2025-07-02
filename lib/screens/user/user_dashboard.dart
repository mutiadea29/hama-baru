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
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              icon: Icons.book,
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
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/riwayat'),
            ),
            _buildDashboardCard(
              icon: Icons.person,
              label: 'Profil',
              count: '',
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/profile'),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(icon, size: 40, color: color),
              if (count.isNotEmpty)
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Text("View Details", style: TextStyle(color: color)),
              )
            ],
          ),
        ),
      ),
    );
  }
}