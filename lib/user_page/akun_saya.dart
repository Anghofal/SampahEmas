import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';

class AkunSayaPage extends StatelessWidget {
  const AkunSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AkunSayaPageFull();
  }
}

class AkunSayaPageFull extends StatefulWidget {
  const AkunSayaPageFull({super.key});

  @override
  State<StatefulWidget> createState() => _AkunSayaPageFull();
}

class _AkunSayaPageFull extends State<AkunSayaPageFull> {
  bool _isLoading = true;
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  Akun? _akun;

  @override
  void initState() {
    super.initState();
    
    _getCurrentUser();
  }

  Future<void> logout(BuildContext context) async {
  try {
    // Melakukan logout dari Firebase
    await FirebaseAuth.instance.signOut();

    // Mengarahkan pengguna ke halaman login
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    // Jika terjadi error, tampilkan pesan error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal logout: ${e.toString()}')),
    );
  }
}

  Future<void> confirmLogout(BuildContext context) async {
  bool shouldLogout = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi Logout'),
        content: Text('Apa yakin Anda ingin logout dari akun ini?'),
        actions: <Widget>[
          TextButton(
            child: Text('Tidak'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text('Ya'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  if (shouldLogout) {
    await logout(context);
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

void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 0:
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      break;
    case 1:
      Navigator.pushNamedAndRemoveUntil(context, '/sampah_saya', ModalRoute.withName('/dashboard'));
      break;
    case 2:
      Navigator.pushNamedAndRemoveUntil(context, '/lokasi', ModalRoute.withName('/dashboard'));
      break;
    case 3:
      Navigator.pushNamedAndRemoveUntil(context, '/akun_saya', ModalRoute.withName('/dashboard'));
      break;
  }
}

  void _onJualPressed() {
    Navigator.pushNamed(context, '/jual_page');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
  
  _selectedIndex = 4;
    
  return _isLoading
          ? Scaffold(
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
                  backgroundColor: darkblueColor,
                  automaticallyImplyLeading: false,
                  title: Row(
            children: [
              Image.asset(
                'assets/logo/Sample Logo Sampah Emas.png',
                height: 40, // Sesuaikan ukuran logo sesuai kebutuhan
              ),
              SizedBox(width: 10), // Jarak antara logo dan teks
              Text(
                'Rp. ${_akun!.balance}', // Ganti ini dengan nilai dinamis jika perlu
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
                body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama: ${_akun!.nama}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Balance: Rp. ${_akun!.balance}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Provinsi: ${_akun!.provinsi}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Kota: ${_akun!.kota}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Kecamatan: ${_akun!.kecamatan}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Kelurahan: ${_akun!.kelurahan}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("Alamat: ${_akun!.alamat}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text("RT/RW: ${_akun!.rw} / ${_akun!.rt}", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Handle logout action
                  confirmLogout(context);
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 16),
                      Text("Logout", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Handle settings action
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blue),
                      SizedBox(width: 16),
                      Text("Pengaturan", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
                height: screenSize.height * 0.08,
                child: BottomNavigationBar(
                backgroundColor: darkblueColor,
                items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // Item kosong untuk memberikan jarak
                  label: '', // Label kosong
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  label: 'Lokasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Akun',
                ),
                        ],
                        currentIndex: _selectedIndex,
                        selectedItemColor: yellowColor, // Warna teks dan ikon item yang dipilih
                        unselectedItemColor: lightgreenColor, // Warna teks dan ikon item yang tidak dipilih
                        onTap: _onItemTapped,
                        type: BottomNavigationBarType.fixed,
                      ),
              ),
                  floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 30.0), // Adjust the value as needed
            child: SizedBox(
              width: 80.0, // Sesuaikan dengan ukuran yang diinginkan
              height: 80.0, // Sesuaikan dengan ukuran yang diinginkan
              child: FloatingActionButton(
                backgroundColor: lightgreenColor,
                onPressed: _onJualPressed,
                tooltip: 'Jual',
                shape: CircleBorder(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: darkgreenColor,),
                    SizedBox(height: 4),
                    Text('Jual', style: TextStyle(fontSize: 12, color: darkblueColor)),
                  ],
                ),
              ),
            ),
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
  }
}