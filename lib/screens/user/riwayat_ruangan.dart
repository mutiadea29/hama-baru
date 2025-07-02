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
      // Use a gradient background to give a modern feel
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Customized AppBar replacement with padding and elevation effect
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Riwayat Ruangan",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Search Field with refined styling
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            hintText: 'Cari ruangan...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Data table wrapped inside an expanded card with padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
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
                            return const Center(child: Text('Tidak ada data riwayat.'));
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
                                    fontSize: 16,
                                  ),
                                  dataTextStyle: const TextStyle(
                                    fontSize: 14,
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
                                    final dataMap = doc.data() as Map<String, dynamic>;
                                    final ruangan = dataMap['ruangan'] ?? '-';
                                    final tanggal = dataMap['tanggal'] ?? '-';
                                    final kapasitas =
                                        dataMap['kapasitas']?.toString() ?? '-';
                                    final status = dataMap['riwayat_status'] ?? '-';

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(ruangan)),
                                        DataCell(Text(tanggal)),
                                        DataCell(Text('$kapasitas orang')),
                                        DataCell(
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color: status == 'selesai'
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
