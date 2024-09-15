import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';
import 'package:sampah_emas/models/laporan.dart';

class ListRtStaffPage extends StatelessWidget {
  const ListRtStaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListRtStaffPageFull();
  }
}

class ListRtStaffPageFull extends StatefulWidget {
  const ListRtStaffPageFull({super.key});

  @override
  State<StatefulWidget> createState() => _ListRtStaffPageFull();
}

class _ListRtStaffPageFull extends State<ListRtStaffPageFull> {
  bool _isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<String> daerahKerjaList = [];
  List<Laporan> laporanList = [];

  User? _user;
  Akun? _akun;

  String formattedDate = '';
  String daerahKerjaGlobal = '';


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

  try {
    await _getCurrentUser();

    formattedDate = ModalRoute.of(context)?.settings.arguments as String;

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

  Future<void> updateLaporanFromFirestore() async {
  try {
    
    // Firestore collection reference
    CollectionReference collectionRef = FirebaseFirestore.instance.collection(
      'laporan/laporan/${_akun!.wilayah_kerja}/rt/$daerahKerjaGlobal/$formattedDate',
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

        // Check if 'status_laporan' is 'perjalanan_pemilah'
        if (data['status_laporan'] == 'perjalanan_pemilah') {
          // Update the 'status_laporan' field to a new value
          await doc.reference.update({
            'status_laporan': 'menunggu_dipilah', // Ganti 'status_baru' dengan nilai yang diinginkan
            'tanggal_waktu_dipenampung': DateTime.now(),
          });
          print("Updated status_laporan for document with ID: ${doc.id}"); // Debugging line
        }

        print("Added document with ID: ${doc.id}"); // Debugging line
      } catch (e) {
        print("Error parsing document ${doc.id}: $e"); // Error handling for parsing
      }
    }
  } catch (e) {
    print("Error fetching documents: $e"); // Error handling for fetching
  }
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
        //print('User path: $userPath');  // Debug: Print the user path

        // Fetch user data from the actual path
        DocumentSnapshot userSnapshot = await _db.doc(userPath).get();

        if (userSnapshot.exists) {
          setState(() {
            _akun = Akun.fromMap(userSnapshot.data() as Map<String, dynamic>);
            if (_akun != null) { // Check if _akun is not null before calling
                tambahDaerahKerjaKeList(_akun!.daerah_kerja);
              }
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

  }
}

void tambahDaerahKerjaKeList(String daerahKerja) {
  // Memisahkan string berdasarkan '/'
  List<String> daerahList = daerahKerja.split('/');

  // Menambahkan setiap item dari daerahList ke list luar
  daerahList.forEach((daerah) {
    daerahKerjaList.add(daerah);
  });
}

  @override
  Widget build(BuildContext context) {
   // final String formattedDate = ModalRoute.of(context)?.settings.arguments as String;
    
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
        title: Text(formattedDate, style: TextStyle(color: yellowColor)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: darkblueColor,
      ),
        body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: daerahKerjaList.map((daerahKerja) {
              return GestureDetector(
                onTap: () {
                  // Aksi ketika container di-tap, mengirim dua variabel ke halaman berikutnya
                  Navigator.pushNamedAndRemoveUntil(
                    context, 
                    '/list_alamat_pilah', // Nama route tujuan
                    ModalRoute.withName('/list_rt_pilah'),
                    arguments: {
                      'formattedDate': formattedDate,  // Mengirim formattedDate
                      'daerahKerja': daerahKerja       // Mengirim pilihan daerah kerja
                    },
                  );
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
                        daerahKerja,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.chevron_right, color: Colors.grey),
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