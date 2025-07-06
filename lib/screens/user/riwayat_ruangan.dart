import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatRuangan extends StatefulWidget {
  const RiwayatRuangan({super.key});

  @override
  State<RiwayatRuangan> createState() => _RiwayatRuanganState();
}

class _RiwayatRuanganState extends State<RiwayatRuangan> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          "Riwayat Ruangan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Cari ruangan...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Table
            Expanded(
              child: Card(
                elevation: 8,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('booking')
                        .orderBy('dibuat', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Terjadi kesalahan.'));
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!.docs.where((doc) {
                        final dataMap = doc.data() as Map<String, dynamic>;
                        final riwayat = dataMap['riwayat_status'];
                        final ruangan = dataMap['ruangan'] ?? '';
                        final isMatched = ruangan
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());
                        return (riwayat == 'selesai' || riwayat == 'batal') &&
                            isMatched;
                      }).toList();

                      if (data.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada data riwayat.'),
                        );
                      }

                      return Scrollbar(
                        thumbVisibility: true,
                        radius: const Radius.circular(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 36,
                              headingRowColor: MaterialStateProperty.all(
                                  Colors.blue.shade50),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              border: TableBorder.symmetric(
                                inside: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              columns: const [
                                DataColumn(label: Text('Nama Ruangan')),
                                DataColumn(label: Text('Tanggal')),
                                DataColumn(label: Text('Kapasitas')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: data.map((doc) {
                                final dataMap =
                                    doc.data() as Map<String, dynamic>;
                                final ruangan = dataMap['ruangan'] ?? '-';
                                final tanggal = dataMap['tanggal'] ?? '-';
                                final kapasitas =
                                    dataMap['kapasitas']?.toString() ?? '-';
                                final status = dataMap['riwayat_status'] ?? '-';

                                Color statusColor;
                                if (status == 'selesai') {
                                  statusColor = Colors.green.shade600;
                                } else if (status == 'batal') {
                                  statusColor = Colors.red.shade600;
                                } else {
                                  statusColor = Colors.grey.shade600;
                                }

                                return DataRow(
                                  cells: [
                                    DataCell(Text(ruangan)),
                                    DataCell(Text(tanggal)),
                                    DataCell(Text('$kapasitas orang')),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
