import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserStatusBookingPage extends StatelessWidget {
  const UserStatusBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Status Booking')),
      body:
          userEmail == null
              ? const Center(child: Text('User tidak ditemukan'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('booking')
                        .where('email', isEqualTo: userEmail)
                        .orderBy('dibuat', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text('Error memuat data'));
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  final bookings = snapshot.data?.docs ?? [];

                  if (bookings.isEmpty)
                    return const Center(child: Text('Belum ada booking'));

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final data =
                          bookings[index].data() as Map<String, dynamic>;
                      final status =
                          data['status']?.toString().trim() ?? 'menunggu';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(data['ruangan'] ?? 'Ruangan'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tanggal: ${data['tanggal']}'),
                              Text('Waktu: ${data['waktu']}'),
                              Text('Keterangan: ${data['keterangan'] ?? '-'}'),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _statusColor(status),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
