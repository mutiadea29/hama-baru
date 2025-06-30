import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_ruangan_page.dart';

class DaftarRuanganPage extends StatelessWidget {
  const DaftarRuanganPage({super.key});

  void hapusRuangan(String id, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('ruangan').doc(id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ruangan berhasil dihapus')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus ruangan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Ruangan')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('ruangan')
                .orderBy('dibuat', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ruanganList = snapshot.data!.docs;

          if (ruanganList.isEmpty) {
            return const Center(child: Text('Belum ada ruangan.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ruanganList.length,
            itemBuilder: (context, index) {
              final doc = ruanganList[index];
              final data = doc.data() as Map<String, dynamic>;

              final nama = data['nama'] ?? '-';
              final lokasi = data['lokasi'] ?? '-';
              final kapasitas = data['kapasitas']?.toString() ?? '-';
              final statusBool = data['status'] == true;
              final statusText = statusBool ? 'Sudah Dipesan' : 'Belum Dipesan';
              final statusColor = statusBool ? Colors.red : Colors.green;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: Checkbox(
                    value: false,
                    onChanged: null, // visual-only, tidak aktif
                  ),
                  title: Text(
                    '$nama • Kapasitas: $kapasitas',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      Text(' $lokasi'),
                      const SizedBox(width: 12),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EditRuanganPage(
                                    id: doc.id,
                                    nama: nama,
                                    lokasi: lokasi,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusRuangan(doc.id, context),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/tambah-ruangan'),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Ruangan'),
      ),
    );
  }
}
