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

  Widget buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'disetujui':
        color = Colors.green.shade600;
        break;
      case 'ditolak':
        color = Colors.red.shade600;
        break;
      case 'menunggu':
        color = Colors.orange.shade600;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Kelola Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 3,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            alignment: Alignment.centerLeft,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              value: statusFilter,
              items: ['semua', 'menunggu', 'disetujui', 'ditolak']
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    statusFilter = value;
                  });
                }
              },
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
                  return const Center(child: Text('Tidak ada data booking.'));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final doc = bookings[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.event, color: Colors.blue),
                        ),
                        title: Text(
                          '${data['ruangan']} - ${data['tanggal']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Waktu: ${data['waktu']}'),
                              Text('User: ${data['user_email']}'),
                              const SizedBox(height: 6),
                              buildStatusChip(data['status']),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'Aksi',
                          onSelected: (value) => updateStatus(id, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'disetujui',
                              child: ListTile(
                                leading: Icon(Icons.check, color: Colors.green),
                                title: Text('Setujui'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'ditolak',
                              child: ListTile(
                                leading: Icon(Icons.close, color: Colors.red),
                                title: Text('Tolak'),
                              ),
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
