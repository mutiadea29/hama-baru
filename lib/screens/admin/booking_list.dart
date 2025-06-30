import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingList extends StatefulWidget {
  const BookingList({super.key});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  String statusFilter = 'semua';

  Future<void> updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('booking').doc(docId).update({
      'status': newStatus,
    });
  }

  Stream<QuerySnapshot> getFilteredBookings(String status) {
    final query = FirebaseFirestore.instance.collection('booking');
    if (status == 'semua') {
      return query.orderBy('created_at', descending: true).snapshots();
    } else {
      return query
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Booking')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: statusFilter,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    statusFilter = value;
                  });
                }
              },
              items:
                  ['semua', 'menunggu', 'disetujui', 'ditolak']
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ),
                      )
                      .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFilteredBookings(statusFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada data booking'));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final doc = bookings[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text('${data['ruangan']} - ${data['tanggal']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Waktu: ${data['waktu']}'),
                            Text('User: ${data['user_email']}'),
                            Text('Status: ${data['status']}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) => updateStatus(id, value),
                          itemBuilder:
                              (context) => [
                                const PopupMenuItem(
                                  value: 'disetujui',
                                  child: Text('Setujui'),
                                ),
                                const PopupMenuItem(
                                  value: 'ditolak',
                                  child: Text('Tolak'),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
