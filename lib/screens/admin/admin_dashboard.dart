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
                        () => _navigateTo(context, const VerifikasiBookingPage()),
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
                    onTap: () =>
                        _navigateTo(context, const AdminManageBookingPage()),
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
          childAspectRatio: 1,
          children: [
            _buildAdminCard(
              icon: Icons.meeting_room,
              label: 'Daftar Ruangan',
              color: Colors.blue,
              onTap: () => _navigateTo(context, const DaftarRuanganPage()),
            ),
            _buildAdminCard(
              icon: Icons.add_business,
              label: 'Tambah Ruangan',
              color: Colors.green,
              onTap: () => _navigateTo(context, const AddRoomPage()),
            ),
            _buildAdminCard(
              icon: Icons.check_circle_outline,
              label: 'Verifikasi Booking',
              color: Colors.orange,
              onTap: () => _navigateTo(context, const VerifikasiBookingPage()),
            ),
            _buildAdminCard(
              icon: Icons.history,
              label: 'Riwayat Booking',
              color: Colors.deepPurple,
              onTap: () => _navigateTo(context, const AdminRiwayatPage()),
            ),
            _buildAdminCard(
              icon: Icons.list_alt,
              label: 'Kelola Booking',
              color: Colors.teal,
              onTap: () => _navigateTo(context, const AdminManageBookingPage()),
            ),
            _buildAdminCard(
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

  Widget _buildAdminCard({
    required IconData icon,
    required String label,
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
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Lihat Detail',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
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