import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormBookingPage extends StatefulWidget {
  const FormBookingPage({super.key});

  @override
  State<FormBookingPage> createState() => _FormBookingPageState();
}

class _FormBookingPageState extends State<FormBookingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedRuangan;
  String? _selectedWaktu;
  final _tanggalController = TextEditingController();
  final _keteranganController = TextEditingController();

  final List<String> _daftarWaktu = [
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];

  Future<void> _selectTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final ruangan = _selectedRuangan!;
    final tanggal = _tanggalController.text.trim();
    final waktu = _selectedWaktu!;
    final keterangan = _keteranganController.text.trim();
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pengguna belum login')));
      return;
    }

    try {
      // Cek apakah sudah ada booking pada waktu yang sama
      final snapshot =
          await FirebaseFirestore.instance
              .collection('booking')
              .where('ruangan', isEqualTo: ruangan)
              .where('tanggal', isEqualTo: tanggal)
              .where('waktu', isEqualTo: waktu)
              .where('status', isNotEqualTo: 'ditolak')
              .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ruangan sudah dibooking di waktu tersebut'),
          ),
        );
        return;
      }

      // Simpan booking
      await FirebaseFirestore.instance.collection('booking').add({
        'email': userEmail,
        'ruangan': ruangan,
        'tanggal': tanggal,
        'waktu': waktu,
        'keterangan': keterangan,
        'status': 'menunggu',
        'dibuat': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Booking berhasil dikirim')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim booking: $e')));
    }
  }

  Future<List<String>> _ambilRuangan() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('ruangan').get();
    return snapshot.docs.map((doc) => doc['nama'] as String).toList();
  }

  @override
  void dispose() {
    _tanggalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Booking Ruangan'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<String>>(
          future: _ambilRuangan(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final ruanganList = snapshot.data ?? [];

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Ruangan',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        ruanganList
                            .map(
                              (nama) => DropdownMenuItem(
                                value: nama,
                                child: Text(nama),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedRuangan = val),
                    validator:
                        (val) => val == null ? 'Ruangan wajib dipilih' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _tanggalController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Booking (YYYY-MM-DD)',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () => _selectTanggal(context),
                      ),
                    ),
                    validator:
                        (val) =>
                            val == null || val.isEmpty
                                ? 'Tanggal wajib diisi'
                                : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Waktu',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _daftarWaktu
                            .map(
                              (waktu) => DropdownMenuItem(
                                value: waktu,
                                child: Text(waktu),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedWaktu = val),
                    validator:
                        (val) => val == null ? 'Waktu wajib dipilih' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _keteranganController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _submitBooking,
                    icon: const Icon(Icons.check),
                    label: const Text('Konfirmasi Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
