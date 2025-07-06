import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRuanganPage extends StatelessWidget {
  const AdminRuanganPage({super.key});

  void hapusRuangan(String id) {
    FirebaseFirestore.instance.collection('ruangan').doc(id).delete();
  }

  void showForm(BuildContext context, {DocumentSnapshot? ruangan}) {
    final namaController = TextEditingController(
      text: ruangan?.get('nama') ?? '',
    );
    final lokasiController = TextEditingController(
      text: ruangan?.get('lokasi') ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          ruangan == null ? 'Tambah Ruangan' : 'Edit Ruangan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Ruangan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final data = {
                'nama': namaController.text,
                'lokasi': lokasiController.text,
              };

              if (ruangan == null) {
                FirebaseFirestore.instance.collection('ruangan').add(data);
              } else {
                FirebaseFirestore.instance
                    .collection('ruangan')
                    .doc(ruangan.id)
                    .update(data);
              }

              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text('Data Ruangan'),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showForm(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ruangan').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(child: Text('Belum ada ruangan.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final ruangan = data[index];
              final nama = ruangan['nama'];
              final lokasi = ruangan['lokasi'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: const Icon(Icons.meeting_room_rounded,
                      color: Colors.blueAccent),
                  title: Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('Lokasi: $lokasi'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.indigo),
                        onPressed: () => showForm(context, ruangan: ruangan),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusRuangan(ruangan.id),
                        tooltip: 'Hapus',
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
