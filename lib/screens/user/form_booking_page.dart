import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FormBookingPage extends StatefulWidget {
  const FormBookingPage({super.key});

  @override
  State<FormBookingPage> createState() => _FormBookingPageState();
}

class _FormBookingPageState extends State<FormBookingPage> {
  final _formKey = GlobalKey<FormState>();
  List<String> roomList = [];
  List<String> waktuList = [
    '08.00 - 10.00',
    '10.00 - 12.00',
    '13.00 - 15.00',
    '15.00 - 17.00',
  ];

  String? selectedRoom;
  DateTime? selectedDate;
  String? selectedTime;
  String keterangan = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('ruangan')
            .where('aktif', isEqualTo: true)
            .get();

    setState(() {
      roomList = snapshot.docs.map((doc) => doc['nama'].toString()).toList();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: 'Pilih tanggal booking',
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<bool> _checkBentrokBooking() async {
    if (selectedRoom == null || selectedDate == null || selectedTime == null) {
      return false;
    }

    final tanggal = DateFormat('yyyy-MM-dd').format(selectedDate!);

    final query =
        await FirebaseFirestore.instance
            .collection('booking')
            .where('ruangan', isEqualTo: selectedRoom)
            .where('tanggal', isEqualTo: tanggal)
            .where('waktu', isEqualTo: selectedTime)
            .where('status', whereIn: ['menunggu', 'disetujui'])
            .get();

    return query.docs.isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        selectedRoom == null ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lengkapi semua data')));
      return;
    }

    setState(() => isLoading = true);

    final isBentrok = await _checkBentrokBooking();

    if (isBentrok) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruangan sudah dibooking di waktu itu')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final bookingData = {
      'email': user?.email,
      'ruangan': selectedRoom,
      'tanggal': DateFormat('yyyy-MM-dd').format(selectedDate!),
      'waktu': selectedTime,
      'keterangan': keterangan.trim(),
      'status': 'menunggu',
      'dibuat': Timestamp.now(),
      'dibuat': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('booking').add(bookingData);

    setState(() => isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Booking berhasil disimpan')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Ruangan')),
      body:
          roomList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Pilih Ruangan'),
                        items:
                            roomList.map((room) {
                              return DropdownMenuItem(
                                value: room,
                                child: Text(room),
                              );
                            }).toList(),
                        onChanged: (value) => selectedRoom = value,
                        validator:
                            (value) =>
                                value == null ? 'Ruangan wajib dipilih' : null,
                      ),
                      ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text(
                          selectedDate == null
                              ? 'Pilih Tanggal'
                              : DateFormat('dd MMM yyyy').format(selectedDate!),
                        ),
                        onTap: _pickDate,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Pilih Waktu'),
                        items:
                            waktuList.map((time) {
                              return DropdownMenuItem(
                                value: time,
                                child: Text(time),
                              );
                            }).toList(),
                        onChanged: (value) => selectedTime = value,
                        validator:
                            (value) =>
                                value == null ? 'Waktu wajib dipilih' : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Keterangan'),
                        onChanged: (value) => keterangan = value,
                        maxLines: 2,
                      ),
                      SizedBox(height: 24),
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _submit,
                            child: Text('Konfirmasi Booking'),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
