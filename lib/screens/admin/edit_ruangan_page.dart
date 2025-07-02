import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRuanganPage extends StatefulWidget {
  final String id;
  final String nama;
  final String lokasi;

  const EditRuanganPage({
    super.key,
    required this.id,
    required this.nama,
    required this.lokasi,
  });


  @override
  State<EditRuanganPage> createState() => _EditRuanganPageState();
}

class _EditRuanganPageState extends State<EditRuanganPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController kapasitasController = TextEditingController();
  bool status = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill data awal
    namaController.text = widget.nama;
    lokasiController.text = widget.lokasi;
    _loadAdditionalFields(); // Ambil data kapasitas & status
  }

  Future<void> _loadAdditionalFields() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('ruangan')
            .doc(widget.id)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      kapasitasController.text = (data['kapasitas'] ?? '').toString();
      status = data['status'] ?? false;
      setState(() {});
    }
  }

  Future<void> simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('ruangan')
            .doc(widget.id)
            .update({
              'nama': namaController.text.trim(),
              'lokasi': lokasiController.text.trim(),
              'kapasitas': int.tryParse(kapasitasController.text.trim()) ?? 0,
              'status': status,
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruangan berhasil diperbarui')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    lokasiController.dispose();
    kapasitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Ruangan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Ruangan'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kapasitasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Kapasitas tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Status:'),
                  const SizedBox(width: 12),
                  DropdownButton<bool>(
                    value: status,
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text('Belum Dipesan'),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('Sudah Dipesan'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        status = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: simpanPerubahan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
