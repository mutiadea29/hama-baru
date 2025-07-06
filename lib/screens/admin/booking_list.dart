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
    try {
      await FirebaseFirestore.instance.collection('booking').doc(docId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status booking diubah ke ${newStatus.toUpperCase()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'disetujui':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle;
        break;
      case 'ditolak':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        icon = Icons.cancel;
        break;
      case 'menunggu':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.hourglass_bottom;
        break;
      default:
        bgColor = Colors.grey.shade300;
        textColor = Colors.grey.shade700;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 13,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Kelola Booking',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_list, color: Colors.blue.shade700),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              value: statusFilter,
              items: ['semua', 'menunggu', 'disetujui', 'ditolak']
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
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
              dropdownColor: Colors.white,
              elevation: 8,
              style: const TextStyle(fontSize: 16),
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
                  return Center(
                    child: Text(
                      'Tidak ada data booking.',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                  );
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final doc = bookings[index];
                    final data = doc.data()! as Map<String, dynamic>;
                    final id = doc.id;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shadowColor: Colors.blue.withOpacity(0.2),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          // Bisa tambahkan aksi saat tap
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(Icons.event_available, size: 32, color: Colors.blue),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['ruangan'] ?? '-',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['tanggal'] ?? '-',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Waktu: ${data['waktu'] ?? '-'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'User: ${data['user_email'] ?? '-'}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 6),
                                    buildStatusChip(data['status'] ?? ''),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                                tooltip: 'Aksi',
                                onSelected: (value) => updateStatus(id, value),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'disetujui',
                                    child: ListTile(
                                      leading: Icon(Icons.check_circle, color: Colors.green.shade700),
                                      title: const Text('Setujui'),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'ditolak',
                                    child: ListTile(
                                      leading: Icon(Icons.cancel, color: Colors.red.shade700),
                                      title: const Text('Tolak'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
