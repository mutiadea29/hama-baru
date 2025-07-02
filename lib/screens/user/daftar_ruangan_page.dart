import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DaftarRuanganPage extends StatelessWidget {
  const DaftarRuanganPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Ruangan')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ruangan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final ruangan = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ruangan.length,
            itemBuilder: (context, index) {
              final data = ruangan[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nama'] ?? ''),
                subtitle: Text(data['deskripsi'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
