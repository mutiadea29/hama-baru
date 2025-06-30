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
      builder:
          (context) => AlertDialog(
            title: Text(ruangan == null ? 'Tambah Ruangan' : 'Edit Ruangan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Ruangan'),
                ),
                TextField(
                  controller: lokasiController,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
              ],
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
      appBar: AppBar(
        title: const Text('Data Ruangan'),
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
            itemCount: data.length,
            itemBuilder: (context, index) {
              final ruangan = data[index];
              final nama = ruangan['nama'];
              final lokasi = ruangan['lokasi'];

              return ListTile(
                title: Text(nama),
                subtitle: Text('Lokasi: $lokasi'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => showForm(context, ruangan: ruangan),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => hapusRuangan(ruangan.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
