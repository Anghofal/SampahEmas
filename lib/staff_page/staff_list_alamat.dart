import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';
import 'package:sampah_emas/models/laporan.dart';

class ListAlamatStaffPage extends StatelessWidget {
  const ListAlamatStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListAlamatStaffPageFull();
  }
}

class ListAlamatStaffPageFull extends StatefulWidget {
  const ListAlamatStaffPageFull({super.key});

  @override
  State<StatefulWidget> createState() => _ListAlamatStaffPageFull();
}

class _ListAlamatStaffPageFull extends State<ListAlamatStaffPageFull> {
  bool _isLoading = true;
  String formattedDate = '';
  String daerahKerja = '';
  String userLaporanPath = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  List<Laporan> laporanList = [];
  Akun? _akun;
  //Laporan? _laporan;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _isLoading = true;
    });
    try{
    // Tunggu sampai _getCurrentUser selesai
    await _getCurrentUser();

    // Buat sebuah Completer untuk menunggu data dari halaman sebelumnya
    Completer<void> argumentsCompleter = Completer<void>();

    // Ambil data dari halaman sebelumnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic> arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

      setState(() {
        formattedDate = arguments['formattedDate'];
        daerahKerja = arguments['daerahKerja'];
      });

      // Tandai bahwa data sudah diperoleh
      argumentsCompleter.complete();
    });

    // Tunggu sampai data dari halaman sebelumnya didapatkan
    await argumentsCompleter.future;

    // Setelah semua data tersedia, panggil getLaporanFromFirestore
    await getLaporanFromFirestore();
    }
    catch (e) {
      print("Error fetching documents: $e"); // Error handling for fetching
    } 
    finally {
      setState(() {
        _isLoading = false; // Set loading state to false once data fetch is complete
      });
    }
  }

Future<void> getLaporanFromFirestore() async {
  /*setState(() {
    _isLoading = true; // Set loading state to true before starting data fetch
  });*/
  
  try {

    userLaporanPath = 'laporan/laporan/${_akun!.wilayah_kerja}/rt/$daerahKerja/$formattedDate';
    // Firestore collection reference for '1 September 2024'
    CollectionReference collectionRef = FirebaseFirestore.instance.collection(
      //'laporan/laporan/provinsi/Jawa Timur/kota/Kota Surabaya/kecamatan/Kecamatan Wonokromo/kelurahan/Kelurahan Wonokromo/rw/RW 01/rt/RT 03/1 September 2024',
      'laporan/laporan/${_akun!.wilayah_kerja}/rt/$daerahKerja/$formattedDate',
      
    );

    // Fetch all documents in the collection
    QuerySnapshot snapshot = await collectionRef.get();

    print("Fetched ${snapshot.docs.length} documents."); // Debugging line

    if (snapshot.docs.isEmpty) {
      print("No documents found in the collection.");
    }

    // Iterate through the documents and map to Laporan objects
    laporanList.clear(); // Clear previous data
    for (var doc in snapshot.docs) {
      try {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Laporan laporan = Laporan.fromMap(data);
        laporanList.add(laporan);
        print("Added document with ID: ${doc.id}"); // Debugging line
      } catch (e) {
        print("Error parsing document ${doc.id}: $e"); // Error handling for parsing
      }
    }
  } catch (e) {
    print("Error fetching documents: $e"); // Error handling for fetching
  } finally {
    /*setState(() {
      _isLoading = false; // Set loading state to false once data fetch is complete
    });*/
  }
}

Future<void> _getCurrentUser() async {
  /*setState(() {
    _isLoading = true; // Set loading state to true before starting data fetch
  });*/
  try {
    _user = _auth.currentUser;

    if (_user != null) {
      String uid = _user!.uid;

      // Fetch the user path from the user_path collection
      DocumentSnapshot userPathSnapshot = await _db.collection('user_path').doc(uid).get();

      if (userPathSnapshot.exists) {
        String userPath = userPathSnapshot['userPath'];
        //print('User path: $userPath');  // Debug: Print the user path

        // Fetch user data from the actual path
        DocumentSnapshot userSnapshot = await _db.doc(userPath).get();

        if (userSnapshot.exists) {
          setState(() {
            _akun = Akun.fromMap(userSnapshot.data() as Map<String, dynamic>);
          });
        } else {
          print('User data not found at path: $userPath');  // Debug: Print if user data not found
        }
      } else {
        print('User path not found for UID: $uid');  // Debug: Print if user path not found
      }
    } else {
      print('No user currently signed in');  // Debug: Print if no user is signed in
    }
  } catch (e) {
    if (context.mounted) {
      final snackbar = SnackBar(content: Text('Error: $e'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
    print('Error: $e');  // Debug: Print the error
  } finally {
    /*setState(() {
      _isLoading = false;
    });*/
  }
}

String getFormattedDateTime(int decrement) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Hitung tanggal dengan mengurangi nilai decrement
    final editedDate = today.subtract(Duration(days: decrement));

    // Format tanggal
    final formattedDate = '${editedDate.day} ${_getMonthName(editedDate.month)} ${editedDate.year}';
    
    return formattedDate;
  }

  // Fungsi untuk mendapatkan nama bulan
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('laporan/laporan/${_akun!.wilayah_kerja}/rt/$daerahKerja/$formattedDate');
    return _isLoading ? Scaffold(
              backgroundColor: darkgreenColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            )
      : Scaffold(
      backgroundColor: darkgreenColor,
      appBar: AppBar(
        title: Text('Pilah $formattedDate ($daerahKerja)', style: TextStyle(color: yellowColor)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: darkblueColor,
      ),
      body: Padding(
  padding: const EdgeInsets.all(8.0),
  child: SingleChildScrollView(
    child: Column(
      children: laporanList.map((laporan) {
        return GestureDetector(
          onTap: () {
            if (laporan.status_laporan == 'menunggu_distributor') {
              // Tampilkan dialog 'Silahkan Tunggu Distributor'
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Informasi'),
                    content: Text('Silahkan Tunggu Distributor'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } else if (laporan.status_laporan == 'menunggu_dipilah') {
              // Lakukan navigasi jika status_laporan adalah 'menunggu_dipilah'
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/sortir_sampah',
                ModalRoute.withName('/list_alamat_pilah'),
                arguments: {
                  'userLaporanPath': userLaporanPath,
                  'uid_user': laporan.uid_user,
                  'uid_pemilah': _akun!.uid,
                  'daerahKerja': daerahKerja,
                  'formattedDate': formattedDate,
                  'alamat_user':laporan.alamat,
                },
              );
            } else if (laporan.status_laporan == 'sudah_dipilah') {
              // Tampilkan dialog 'Sampah telah dipilah'
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Informasi'),
                    content: Text('Sampah telah dipilah'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  laporan.alamat,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    laporan.status_laporan == 'menunggu_distributor'
                        ? Icons.pending // Ikon menunggu distributor
                        : laporan.status_laporan == 'menunggu_dipilah'
                            ? Icons.camera_alt // Ikon kamera
                            : Icons.check_circle, // Ikon centang untuk 'sudah_dipilah'
                    color: laporan.status_laporan == 'menunggu_distributor'
                        ? Colors.blue // Warna untuk ikon pending
                        : laporan.status_laporan == 'menunggu_dipilah'
                            ? Colors.orange // Warna untuk ikon kamera
                            : Colors.green, // Warna untuk ikon centang
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  ),
),

    );
  }
}
