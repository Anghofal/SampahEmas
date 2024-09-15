import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';

class JualPage extends StatelessWidget {
  const JualPage({super.key});

  @override
  Widget build(BuildContext context) {
    return JualPageFull();
  }
}

class JualPageFull extends StatefulWidget {
  const JualPageFull({super.key});

  @override
  State<StatefulWidget> createState() => _JualPageFull();
}

class _JualPageFull extends State<JualPageFull> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;
  Akun? _akun;
  User? _user;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initializeCamera();
  }

  Future<void> _getCurrentUser() async {
    
  try {
    _user = _auth.currentUser;

    if (_user != null) {
      String uid = _user!.uid;

      // Fetch the user path from the user_path collection
      DocumentSnapshot userPathSnapshot = await _db.collection('user_path').doc(uid).get();

      if (userPathSnapshot.exists) {
        String userPath = userPathSnapshot['userPath'];
        print('User path: $userPath');  // Debug: Print the user path

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
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> uploadToFirebase(String path, Uint8List imageData) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putData(imageData);
      print("Upload successful!");
    } catch (e) {
      print("Error uploading to Firebase: $e");
    }
  }

  Future<void> handlePictureUpload() async {
  try {
    await _initializeControllerFuture;
    final image = await _cameraController!.takePicture();
    final compressedImageData = await compressImage(image);

    // Dapatkan user ID dari Firebase Auth
    User? _user = _auth.currentUser;
    if (_user != null) {
      String uid = _user.uid;

      // Ambil path dari Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('user_path')
          .doc(uid)
          .get();

      String originalPath = snapshot.data()?['userPath'] ?? '';

      // Modifikasi path untuk menghapus "data/" dan menghilangkan string setelah "data/"
      String basePath;
      if (originalPath.contains('data/')) {
        basePath = originalPath.substring(0, originalPath.indexOf('data/'));
        basePath = basePath.substring(0, basePath.lastIndexOf('/') + 1);
      } else {
        basePath = originalPath; // or handle error if necessary
      }

      // Dapatkan tanggal dan waktu yang sesuai
      String dateFolder = getFormattedDateTime();

      // Tambahkan folder tambahan sebelum file image
      String modifiedPath = basePath.replaceFirst('akun/akun', 'laporan') + "$dateFolder";

      // Gunakan UID sebagai nama file
      String fileName = '$uid.jpg';

      // Gabungkan path dan nama file
      String fullPath = '$modifiedPath/$fileName';

      // Upload gambar ke Firebase Storage
      await uploadToFirebase(fullPath, compressedImageData);
    }
  } catch (e) {
    print("Error: $e");
  }
}

  Future<Uint8List> compressImage(XFile imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(imageBytes)!;

    img.Image resizedImage = img.copyResize(image, width: 800);
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 85);

    return Uint8List.fromList(compressedImageBytes);
  }

  Future<void> _initializeCamera() async {
  try {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      print("No cameras found");
      return;
    }
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController?.initialize();
    setState(() {});
  } catch (e) {
    print("Error initializing camera: $e");
  }
}

String getFormattedDateTime() {
  final now = DateTime.now();
  final hour = now.hour;
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(Duration(days: 1));

  // Format tanggal
  final formattedToday = '${today.day} ${_getMonthName(today.month)} ${today.year}';
  final formattedTomorrow = '${tomorrow.day} ${_getMonthName(tomorrow.month)} ${tomorrow.year}';

  // Conditional untuk memutuskan penggunaan tanggal
  if (hour >= 0 && hour < 6) {
    return formattedToday;
  } else {
    return formattedTomorrow;
  }
}

String modifyUserPath(String userPath) {
  // Ganti "akun/akun/" dengan "laporan/laporan/"
  String modifiedUserPath = userPath.replaceFirst("akun/akun/", "laporan/laporan/");
  
  // Temukan indeks "data/" dan hapus string setelahnya
  final indexData = modifiedUserPath.indexOf("data/");
  if (indexData != -1) {
    modifiedUserPath = modifiedUserPath.substring(0, indexData);
  }

  // Pastikan tidak ada '/' yang tersisa di akhir path
  modifiedUserPath = modifiedUserPath.replaceAll(RegExp(r'\/+$'), '');

  return modifiedUserPath;
}

Future<void> uploadLaporanData() async {
  // Dapatkan user ID dari Firebase Auth
  User? _user = _auth.currentUser;
  DateTime dateTimeNow = DateTime.now();
  if (_user != null) {
    String uid = _user.uid;

    // Ambil user path dari Firestore
    DocumentSnapshot userPathSnapshot = await _db.collection('user_path').doc(uid).get();
    if (userPathSnapshot.exists) {
      String userPath = userPathSnapshot['userPath'];

      // Modifikasi user path sesuai dengan aturan waktu
      final formattedDate = getFormattedDateTime();
      String modifiedUserPath = modifyUserPath(userPath);

      final laporanPath = "$modifiedUserPath/$formattedDate/$uid";
      print("Laporan path: $laporanPath");

      // Data yang akan diupload
      final data = {
        'nama': _akun?.nama ?? 'Nama tidak ditemukan',
        'alamat': _akun?.alamat ?? 'Alamat tidak ditemukan',
        'status_laporan': 'menunggu_distributor',
        'sampah_saya': '',
        'berat_distributor': 0,
        'berat_pemilah': 0,
        'uid_user': uid,
        'uid_distributor': '',
        'uid_pemilah': '',
        'tanggal_waktu_upload': dateTimeNow,
        'tanggal_waktu_diambil': dateTimeNow,
        'tanggal_waktu_dipenampung': dateTimeNow,
        'tanggal_waktu_dipilah': dateTimeNow,
      };

      // Upload data ke Firestore
      await _db.doc(laporanPath).set(data);
    } else {
      print('User path not found for UID: $uid');
    }
  } else {
    print('No user currently signed in');
  }
}

Future<bool> checkIfLaporanExists() async {
  // Dapatkan user ID dari Firebase Auth
  User? _user = _auth.currentUser;
  if (_user != null) {
    String uid = _user.uid;

    // Ambil user path dari Firestore
    DocumentSnapshot userPathSnapshot = await _db.collection('user_path').doc(uid).get();
    if (userPathSnapshot.exists) {
      String userPath = userPathSnapshot['userPath'];

      // Modifikasi user path sesuai dengan aturan waktu
      final formattedDate = getFormattedDateTime();
      String modifiedUserPath = modifyUserPath(userPath);

      final laporanPath = "$modifiedUserPath/$formattedDate";
      print("Laporan path: $laporanPath");

      // Lakukan query pengecekan apakah dokumen dengan UID ada di dalam koleksi tersebut
      DocumentSnapshot documentSnapshot = await _db.collection(laporanPath).doc(uid).get();
      if (documentSnapshot.exists) {
        // Jika dokumen dengan UID ditemukan, return true
        return true;
      } else {
        // Jika tidak ditemukan, return false
        return false;
      }
    } else {
      print('User path not found for UID: $uid');
      return false;
    }
  } else {
    print('No user currently signed in');
    return false;
  }
}


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
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkgreenColor,
      appBar: AppBar(
        title: Text('Jual Sampah Mu', style: TextStyle(color: yellowColor)),
        centerTitle: true,
        
        automaticallyImplyLeading: false,
        backgroundColor: darkblueColor,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CameraPreview(_cameraController!),
                        Positioned(
                          bottom: 20.0,
                          child: FloatingActionButton(
                            onPressed: () async {
                              bool shouldUpload = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Konfirmasi'),
                                  content: Text('Sampah anda akan diambil sesuai dengan jam yang anda pilih, yakin ingin dijual?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('Tidak'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Ya'),
                                    ),
                                  ],
                                ),
                              );

                              // Check if laporan already exists
                              bool laporanExists = await checkIfLaporanExists();

                              if (laporanExists) {
                                // Show dialog if the report already exists
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Laporan Sudah Ada"),
                                        content: Text("Laporan untuk hari ini sudah dibuat. Anda tidak dapat membuat laporan duplikat."),
                                        actions: [
                                          TextButton(
                                            child: Text("OK"),
                                            onPressed: () {
                                              Navigator.pushNamedAndRemoveUntil(context, '/sampah_saya', ModalRoute.withName('/dashboard'));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else {
                                if (shouldUpload) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    await uploadLaporanData();
                                    await handlePictureUpload();
                                    
                                    print("Gambar dan data laporan berhasil diupload");

                                  } catch (e) {
                                    print("Error during upload: $e");
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });

                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Laporan Terupload"),
                                            content: Text("Laporan Anda telah berhasil diupload."),
                                            actions: [
                                              TextButton(
                                                child: Text("OK"),
                                                onPressed: () {
                                                  Navigator.pushNamedAndRemoveUntil(context, '/sampah_saya', ModalRoute.withName('/dashboard'));
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                }
                              }
                            },
                            backgroundColor: lightgreenColor,
                            child: Icon(Icons.camera_alt, color: darkgreenColor,),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: darkblueColor,
        height: screenSize.height * 0.1,
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: AutoSizeText(
            "Ambil Gambar Sampah Mu\nDi Depan Tempat Sampah",
            style: TextStyle(
              fontSize: 20,
              color: yellowColor
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            minFontSize: 12,
          ),
        ),
      ),
    );
  }
}