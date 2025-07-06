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
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lokasiController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600),
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
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 3,
        title: const Text(
          'Manajemen Ruangan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Ruangan',
            onPressed: () => showForm(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ruangan').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(child: Text('Belum ada ruangan.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final ruangan = data[index];
              final nama = ruangan['nama'];
              final lokasi = ruangan['lokasi'];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.meeting_room, color: Colors.blue),
                  ),
                  title: Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Lokasi: $lokasi',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.indigo,
                        tooltip: 'Edit',
                        onPressed: () => showForm(context, ruangan: ruangan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent,
                        tooltip: 'Hapus',
                        onPressed: () => hapusRuangan(ruangan.id),
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
