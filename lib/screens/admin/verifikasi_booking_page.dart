import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifikasiBookingPage extends StatelessWidget {
  const VerifikasiBookingPage({super.key});

  Future<void> updateStatus(
    String id,
    String status,
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('booking').doc(id).update({
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status booking diperbarui menjadi "$status"')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Booking')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('booking')
                .where('status', isEqualTo: 'menunggu')
                .orderBy('dibuat', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada permintaan booking.'));
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final booking = data[index];
              final id = booking.id;
              final ruangan = booking['ruangan'] ?? '-';
              final tanggal = booking['tanggal'] ?? '-';
              final waktu = booking['waktu'] ?? '-';
              final keterangan = booking['keterangan'] ?? '-';
              final email = booking['email'] ?? '-';
              final status = booking['status'] ?? 'menunggu';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruangan    : $ruangan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Tanggal    : $tanggal'),
                      Text('Waktu      : $waktu'),
                      Text('Email      : $email'),
                      Text('Keterangan : $keterangan'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            'Status: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            status,
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (status == 'menunggu')
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  () => updateStatus(id, 'disetujui', context),
                              icon: const Icon(Icons.check),
                              label: const Text('Setujui'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed:
                                  () => updateStatus(id, 'ditolak', context),
                              icon: const Icon(Icons.close),
                              label: const Text('Tolak'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                            ),
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
