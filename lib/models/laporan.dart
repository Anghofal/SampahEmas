import 'package:cloud_firestore/cloud_firestore.dart';

class Laporan {
  final String uid_user;
  final String uid_distributor;
  final String uid_pemilah;
  final String alamat;
  final String status_laporan;
  final String sampah_saya;
  final Timestamp tanggal_waktu_upload;
  final Timestamp tanggal_waktu_diambil;
  final Timestamp tanggal_waktu_dipenampung;
  final Timestamp tanggal_waktu_dipilah;
  final double berat_pemilah;
  final double berat_distributor;

  Laporan({
    required this.uid_distributor, 
    required this.uid_pemilah, 
    required this.berat_pemilah, 
    required this.berat_distributor, 
    required this.uid_user,
    required this.alamat,
    required this.status_laporan,
    required this.sampah_saya,
    required this.tanggal_waktu_upload,
    required this.tanggal_waktu_diambil,
    required this.tanggal_waktu_dipenampung,
    required this.tanggal_waktu_dipilah,
    
  });

  factory Laporan.fromMap(Map<String, dynamic> map) {
    Timestamp timestamp = Timestamp.now();
    return Laporan(
      uid_user: map['uid_user'] ?? '',
      uid_distributor: map['uid_distributor'] ?? '',
      uid_pemilah: map['uid_pemilah'] ?? '',
      alamat: map['alamat'] ?? '',
      status_laporan: map['status_laporan'] ?? '',
      sampah_saya: map['sampah_saya'] ?? '',
      tanggal_waktu_upload: map['tanggal_waktu_upload'] ?? timestamp,
      tanggal_waktu_diambil: map['tanggal_waktu_diambil'] ?? timestamp,
      tanggal_waktu_dipenampung: map['tanggal_waktu_dipenampung'] ?? timestamp,
      tanggal_waktu_dipilah: map['tanggal_waktu_dipilah'] ?? timestamp,
      berat_distributor: map['berat_distributor']?.toDouble() ?? 0.0,
      berat_pemilah: map['berat_pemilah']?.toDouble() ?? 0.0,
    );
  }
}
