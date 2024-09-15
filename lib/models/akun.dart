class Akun {
  final String uid;
  final String role;
  final String email;

  final String nama;
  final String provinsi;
  final String kota;
  final String kecamatan;
  final String kelurahan;
  final String rw;
  final String rt;
  final String alamat;

  final String daerah_kerja;
  final String wilayah_kerja;

  final int balance;

  Akun({
    required this.uid,
    required this.email,
    required this.role,
    required this.nama,
    required this.provinsi,
    required this.kota,
    required this.kecamatan,
    required this.kelurahan,
    required this.rw,
    required this.rt,
    required this.alamat,
    required this.balance,
    required this.daerah_kerja,
    required this.wilayah_kerja,

  });

  // Factory constructor untuk inisialisasi dari Map
  factory Akun.fromMap(Map<String, dynamic> map) {
    return Akun(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      alamat: map['alamat'] ?? '',
      provinsi: map['provinsi'] ?? '',
      kota: map['kota'] ?? '',
      kecamatan: map['kecamatan'] ?? '',
      kelurahan: map['kelurahan'] ?? '',
      rw: map['rw'] ?? '',
      rt: map['rt'] ?? '',
      balance: map['balance'] ?? 0,
      daerah_kerja: map['daerah_kerja'] ?? '',
      wilayah_kerja: map['wilayah_kerja'] ?? '',
    );
  }

  // Method untuk konversi ke Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': role,
      'alamat': alamat,
      'provinsi': provinsi,
      'kota': kota,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'rw': rw,
      'rt': rt,
      'balance': balance,
      'daerah_kerja' :daerah_kerja,
    };
  }

}