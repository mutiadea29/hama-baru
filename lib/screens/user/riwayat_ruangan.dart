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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Riwayat Ruangan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
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
                  width: 250,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Cari ruangan...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 16),

            // Tabel Data
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
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

                      final data =
                          snapshot.data!.docs.where((doc) {
                            final dataMap = doc.data() as Map<String, dynamic>;
                            final riwayat = dataMap['riwayat_status'];
                            final ruangan = dataMap['ruangan'] ?? '';
                            final isMatched = ruangan
                                .toString()
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase());
                            return (riwayat == 'selesai' ||
                                    riwayat == 'batal') &&
                                isMatched;
                          }).toList();

                      if (data.isEmpty) {
                        return const Center(
                          child: Text('Tidak ada data riwayat.'),
                        );
                      }

                      return Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 40,
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blue.shade100,
                              ),
                              dataRowHeight: 60,
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
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
                              rows:
                                  data.map((doc) {
                                    final dataMap =
                                        doc.data() as Map<String, dynamic>;
                                    final ruangan = dataMap['ruangan'] ?? '-';
                                    final tanggal = dataMap['tanggal'] ?? '-';
                                    final kapasitas =
                                        dataMap['kapasitas']?.toString() ?? '-';
                                    final status =
                                        dataMap['riwayat_status'] ?? '-';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(ruangan)),
                                        DataCell(Text(tanggal)),
                                        DataCell(Text('$kapasitas orang')),
                                        DataCell(
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color:
                                                  status == 'selesai'
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontWeight: FontWeight.w600,
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
