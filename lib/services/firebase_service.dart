import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference ruanganCollection = FirebaseFirestore.instance
      .collection('ruangan');
  final CollectionReference bookingCollection = FirebaseFirestore.instance
      .collection('booking');

  // Tambah ruangan
  Future<void> tambahRuangan(Map<String, dynamic> data) async {
    await ruanganCollection.add(data);
  }

  // Update ruangan
  Future<void> updateRuangan(String id, Map<String, dynamic> data) async {
    await ruanganCollection.doc(id).update(data);
  }

  // Hapus ruangan
  Future<void> hapusRuangan(String id) async {
    await ruanganCollection.doc(id).delete();
  }

  // Booking ruangan
  Future<void> buatBooking(Map<String, dynamic> data) async {
    await bookingCollection.add(data);
  }

  // Konfirmasi booking
  Future<void> konfirmasiBooking(String id, String status) async {
    await bookingCollection.doc(id).update({'status': status});
  }
}
