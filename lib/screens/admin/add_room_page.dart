import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController kapasitasController = TextEditingController();

  bool status = false; // Sudah Dipesan = true
  bool isAktif = true; // Checkbox status aktif

  final _formKey = GlobalKey<FormState>();

  Future<bool> _isNamaRuanganUnik(String nama) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('ruangan')
            .where('nama', isEqualTo: nama)
            .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> tambahRuangan() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = namaController.text.trim();
    final lokasi = lokasiController.text.trim();
    final kapasitas = int.tryParse(kapasitasController.text.trim()) ?? 0;

    if (kapasitas < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kapasitas harus minimal 1')),
      );
      return;
    }

    final unik = await _isNamaRuanganUnik(nama);
    if (!unik) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama ruangan sudah digunakan')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('ruangan').add({
        'nama': nama,
        'lokasi': lokasi,
        'kapasitas': kapasitas,
        'status': status,
        'aktif': isAktif,
        'dibuat': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruangan berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah ruangan: $e')));
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
      appBar: AppBar(title: const Text('Tambah Ruangan')),
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
                        value == null || value.trim().isEmpty
                            ? 'Nama tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Lokasi tidak boleh kosong'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kapasitasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Kapasitas tidak boleh kosong';
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 1)
                    return 'Kapasitas minimal 1';
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
                    onChanged: (value) => setState(() => status = value!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: isAktif,
                    onChanged: (value) => setState(() => isAktif = value!),
                  ),
                  const Text('Ruangan Aktif'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: tambahRuangan,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Ruangan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
