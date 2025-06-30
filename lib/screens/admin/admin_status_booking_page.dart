import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminStatusBookingPage extends StatelessWidget {
  const AdminStatusBookingPage({super.key});

  Future<void> updateStatus(String id, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('booking').doc(id).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint('Gagal memperbarui status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Status Booking'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('booking')
                .orderBy('created_at', descending: true)
                // .where('status', isEqualTo: 'menunggu') // ← Un-comment jika hanya ingin status menunggu
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text('Tidak ada booking.'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final id = booking.id;
              final data = booking.data() as Map<String, dynamic>;

              final ruangan = data['ruangan'] ?? '-';
              final tanggal = data['tanggal'] ?? '-';
              final waktu = data['waktu'] ?? '-';
              final keterangan = data['keterangan'] ?? '-';
              final email = data['user_email'] ?? '-';
              final status = data['status'] ?? 'menunggu';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruangan: $ruangan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('User: $email'),
                      Text('Tanggal: $tanggal'),
                      Text('Waktu: $waktu'),
                      Text('Keterangan: $keterangan'),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${status.toUpperCase()}',
                            style: TextStyle(
                              color:
                                  status == 'disetujui'
                                      ? Colors.green
                                      : status == 'ditolak'
                                      ? Colors.red
                                      : Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (status == 'menunggu') ...[
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  tooltip: 'Setujui',
                                  onPressed:
                                      () => updateStatus(id, 'disetujui'),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Tolak',
                                  onPressed: () => updateStatus(id, 'ditolak'),
                                ),
                              ],
                            ),
                          ] else
                            const Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
