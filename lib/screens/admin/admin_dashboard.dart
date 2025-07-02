import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:hama/screens/admin/admin_manage_booking.dart';
import 'package:hama/screens/admin/daftar_ruangan_page.dart';
import 'package:hama/screens/admin/add_room_page.dart';
import 'package:hama/screens/admin/verifikasi_booking_page.dart';
import 'package:hama/screens/admin/admin_riwayat_page.dart';
import 'package:hama/screens/user/profile_page.dart';
import 'package:hama/screens/auth/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Row(
                children: const [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Menu Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.meeting_room,
                    title: 'Daftar Ruangan',
                    onTap:
                        () => _navigateTo(context, const DaftarRuanganPage()),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.add_business,
                    title: 'Tambah Ruangan',
                    onTap: () => _navigateTo(context, const AddRoomPage()),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.check_circle_outline,
                    title: 'Verifikasi Booking',
                    onTap:
                        () =>
                            _navigateTo(context, const VerifikasiBookingPage()),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.history,
                    title: 'Riwayat Booking',
                    onTap: () => _navigateTo(context, const AdminRiwayatPage()),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.list_alt,
                    title: 'Kelola Booking',
                    onTap:
                        () => _navigateTo(
                          context,
                          const AdminManageBookingPage(),
                        ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'Profil',
                    onTap: () => _navigateTo(context, const ProfilePage()),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
          children: [
            _DashboardCard(
              icon: Icons.meeting_room,
              label: 'Daftar Ruangan',
              color: Colors.blue,
              onTap: () => _navigateTo(context, const DaftarRuanganPage()),
            ),
            _DashboardCard(
              icon: Icons.add_business,
              label: 'Tambah Ruangan',
              color: Colors.green,
              onTap: () => _navigateTo(context, const AddRoomPage()),
            ),
            _DashboardCard(
              icon: Icons.check_circle_outline,
              label: 'Verifikasi Booking',
              color: Colors.orange,
              onTap: () => _navigateTo(context, const VerifikasiBookingPage()),
            ),
            _DashboardCard(
              icon: Icons.history,
              label: 'Riwayat Booking',
              color: Colors.deepPurple,
              onTap: () => _navigateTo(context, const AdminRiwayatPage()),
            ),
            _DashboardCard(
              icon: Icons.list_alt,
              label: 'Kelola Booking',
              color: Colors.teal,
              onTap: () => _navigateTo(context, const AdminManageBookingPage()),
            ),
            _DashboardCard(
              icon: Icons.person,
              label: 'Profil',
              color: Colors.pink,
              onTap: () => _navigateTo(context, const ProfilePage()),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
