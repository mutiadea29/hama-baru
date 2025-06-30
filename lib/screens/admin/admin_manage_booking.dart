import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminManageBookingPage extends StatefulWidget {
  const AdminManageBookingPage({super.key});

  @override
  State<AdminManageBookingPage> createState() => _AdminManageBookingPageState();
}

class _AdminManageBookingPageState extends State<AdminManageBookingPage> {
  String _selectedStatus = 'Semua';

  final List<String> _statusList = [
    'Semua',
    'menunggu',
    'disetujui',
    'ditolak',
  ];

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('booking').doc(id).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status booking diperbarui menjadi $newStatus.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui status.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('booking')
        .orderBy('dibuat', descending: true);

    if (_selectedStatus != 'Semua') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kelola Booking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedStatus,
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list, color: Colors.white),
              style: const TextStyle(color: Colors.black),
              items:
                  _statusList
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF9F9FB),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Terjadi kesalahan saat memuat data.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada data booking.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final id = doc.id;
                final status = data['status'] ?? 'menunggu';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['ruangan'] ?? 'Tanpa Nama',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow("User", data['user_email']),
                        _buildInfoRow("Tanggal", data['tanggal']),
                        _buildInfoRow("Waktu", data['waktu']),
                        _buildInfoRow("Keterangan", data['keterangan']),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                              style: TextStyle(
                                color:
                                    status == 'disetujui'
                                        ? Colors.green
                                        : status == 'ditolak'
                                        ? Colors.red
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            status == 'menunggu'
                                ? Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      tooltip: 'Setujui',
                                      onPressed:
                                          () => _updateStatus(id, 'disetujui'),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Tolak',
                                      onPressed:
                                          () => _updateStatus(id, 'ditolak'),
                                    ),
                                  ],
                                )
                                : const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
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
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
