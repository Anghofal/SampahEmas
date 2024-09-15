import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:sampah_emas/components/input_widget.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/components/validators.dart';

class SortirSampahNextPage extends StatelessWidget {
  const SortirSampahNextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortirSampahNextPageFull();
  }
}

class SortirSampahNextPageFull extends StatefulWidget {
  const SortirSampahNextPageFull({super.key});
  
  

  @override
  State<StatefulWidget> createState() => _SortirSampahNextPageFull();

}



class _SortirSampahNextPageFull extends State<SortirSampahNextPageFull> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = true;
  User? _user;
  
  String userLaporanPath = '';
  String uid_user = '';
  String uid_pemilah = '';
  String formattedDate = '';
  String daerahKerja = '';
  String alamat_user = '';
  String sampahSaya = '';
  double berat_pemilah = 0.0;

    @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initData();
  });
  }

    @override
    void dispose() {
      _cameraController?.dispose();
      super.dispose();
    }

    Future<void> _initData() async {
  setState(() {
    _isLoading = true;
  });

  try {
    await _initializeCamera();

    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      setState(() {
        userLaporanPath = arguments['userLaporanPath'];
        uid_user = arguments['uid_user'];
        uid_pemilah = arguments['uid_pemilah'];
        formattedDate = arguments['formattedDate'];
        daerahKerja = arguments['daerahKerja'];
        alamat_user = arguments['alamat_user'];
        sampahSaya = arguments['sampah_saya'];

      });
    } else {
      print("Arguments are null");
    }

  } catch (e) {
    print("Error fetching documents: $e");
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false; // Pastikan loading berhenti
      });
    }
  }
}

// Method untuk mengupdate field pada dokumen Firestore
Future<void> updateLaporanDocument() async {
  // Mendapatkan instance Firestore
  final firestore = FirebaseFirestore.instance;

  // Path dokumen yang ingin diupdate
  //final docPath = 'laporan/laporan/provinsi/Jawa Timur/kota/Kota Surabaya/kecamatan/Kecamatan Wonokromo/kelurahan/Kelurahan Wonokromo/rw/RW 01/rt/RT 03/1 September 2024/5Yfs2EY7NMbmSFyE31waiA1rP6M2';
  String docPath = '$userLaporanPath/$uid_user';

  try {
    // Melakukan update pada dokumen Firestore
    await firestore.doc(docPath).update({
      'berat_pemilah': berat_pemilah,
      'status_laporan': 'perjalanan_pemilah',
      'sampah_saya': sampahSaya,
      'uid_pemilah': uid_pemilah,
      'tanggal_waktu_dipilah': DateTime.now(), // Menambahkan tanggal_waktu_ambil
    });
    print('Dokumen berhasil diupdate');
  } catch (e) {
    print('Gagal mengupdate dokumen: $e');
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

      // Ambil path dari Firestore
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('user_path')
          .doc(uid_user)
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
      String dateFolder = getFormattedDateTimeToday();

      // Tambahkan folder tambahan sebelum file image
      String modifiedPath = basePath.replaceFirst('akun/akun', 'laporan_pemilah') + "$dateFolder";

      // Gunakan UID sebagai nama file
      String fileName = '$uid_user.jpg';

      // Gabungkan path dan nama file
      String fullPath = '$modifiedPath/$fileName';

      // Upload gambar ke Firebase Storage
      await uploadToFirebase(fullPath, compressedImageData);
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
  } catch (e) {
    print("Error initializing camera: $e");
  }
}

  String getFormattedDateTimeToday() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Format tanggal
  final formattedToday = '${today.day} ${_getMonthName(today.month)} ${today.year}';

  return formattedToday;
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
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false, // Ini akan menghentikan body dari terdorong ke ata
      backgroundColor: darkgreenColor,
      appBar: AppBar(
              title: AutoSizeText(
                "Foto Sampah Alamat\n$alamat_user",
                style: TextStyle(color: yellowColor),
                textAlign: TextAlign.center,
                maxLines: 2, // Limits the text to two lines
                minFontSize: 10, // Minimum font size to shrink to
                overflow: TextOverflow.ellipsis, // Adds ellipsis if the text is too long
              ),
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
                                backgroundColor: darkgreenColor,
                                title: Text('Konfirmasi',
                                style: TextStyle(color: Colors.white),),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Pastikan Sampah yang telah Dipilah telah terlihat dalam satu foto!',
                                    style: TextStyle(color: Colors.white),),
                                    SizedBox(height: 16.0),
                                    InputLayout('Berat', TextFormField(
                                      onChanged: (String value) => setState(() {
                                        berat_pemilah = double.tryParse(value) ?? 0.0;
                                      }),
                                      keyboardType: TextInputType.number, // Menambahkan tipe input number
                                      validator: notEmptyValidator,
                                      cursorColor: Colors.white,
                                      style: TextStyle(color: Colors.white),
                                      decoration: customInputDecoration("Berat Sampah"),
                                    )),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Tidak',
                                    style: TextStyle(color: Colors.white),),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Ya',
                                    style: TextStyle(color: Colors.white),),
                                  ),
                                ],
                              ),
                            );

                              
                                if (shouldUpload) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    await handlePictureUpload();
                                    await updateLaporanDocument();
                                    //print('path : $userLaporanPath');
                                    //print('date : $formattedDate');
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
                                                  Navigator.pushNamedAndRemoveUntil(context, '/list_alamat_pilah', ModalRoute.withName('/list_tanggal_pilah'),
                                                  arguments: {
                                                    'formattedDate': formattedDate,  // Mengirim formattedDate
                                                    'daerahKerja': daerahKerja       // Mengirim pilihan daerah kerja
                                                  },
                                                );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
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
            const Center(
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
            "Ambil Gambar Sampah Kustomer\nSetelah Dipilah",
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