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
            // Search Field
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

            // Data Table
            Expanded(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.blue.shade100;
                                  }
                                  return Colors.grey.shade50;
                                },
                              ),
                              border: TableBorder.all(
                                color: Colors.grey.shade300,
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

                                // Style badge warna pastel
                                Color badgeColor;
                                Color badgeTextColor;

                                if (status == 'selesai') {
                                  badgeColor = const Color(0xFFE8F5E9); // green bg
                                  badgeTextColor = Colors.green.shade700;
                                } else if (status == 'batal') {
                                  badgeColor = const Color(0xFFFFEBEE); // red bg
                                  badgeTextColor = Colors.red.shade700;
                                } else {
                                  badgeColor = Colors.grey.shade200;
                                  badgeTextColor = Colors.grey.shade800;
                                }

                                return DataRow(
                                  cells: [
                                    DataCell(Text(
                                      ruangan,
                                      style: const TextStyle(fontSize: 14),
                                    )),
                                    DataCell(Text(
                                      tanggal,
                                      style: const TextStyle(fontSize: 14),
                                    )),
                                    DataCell(Text(
                                      '$kapasitas orang',
                                      style: const TextStyle(fontSize: 14),
                                    )),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: badgeColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            color: badgeTextColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
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
