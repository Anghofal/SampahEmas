import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';

class InDevelopment extends StatelessWidget {
  const InDevelopment({super.key});

  @override
  Widget build(BuildContext context) {
    return InDevelopmentFull();
  }
}

class InDevelopmentFull extends StatefulWidget {
  const InDevelopmentFull({super.key});

  @override
  State<StatefulWidget> createState() => _InDevelopmentFull();
}

class _InDevelopmentFull extends State<InDevelopmentFull> {
  bool _isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  Akun? _akun;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              backgroundColor: darkgreenColor,
            ),
          )
        : Scaffold(
            backgroundColor: darkgreenColor,
            appBar: AppBar(
              automaticallyImplyLeading: false, // Menghilangkan tombol back
              backgroundColor: darkblueColor,
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo/Sample Logo Sampah Emas.png',
                    height: 40, // Sesuaikan ukuran logo sesuai kebutuhan
                  ),
                  SizedBox(width: 10), // Jarak antara logo dan teks
                  Text(
                    'Rp. ${_akun?.balance ?? 'Loading...'}', // Ganti ini dengan nilai dinamis jika perlu
                    style: TextStyle(fontSize: 18, color: yellowColor), // Sesuaikan ukuran teks
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.mail, color: yellowColor),
                  onPressed: () {
                    // Aksi ketika tombol ditekan
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Memusatkan konten di tengah
                  children: [
                    Icon(
                      Icons.construction,
                      size: 100,
                      color: yellowColor,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Page Ini Masih Dalam Tahap Pengembangan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: yellowColor),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
