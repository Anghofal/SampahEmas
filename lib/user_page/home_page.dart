import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePageFull();
  }
}

class HomePageFull extends StatefulWidget {
  const HomePageFull({super.key});
  
  

  @override
  State<StatefulWidget> createState() => _HomePageFull();

}



class _HomePageFull extends State<HomePageFull> {
  bool _isLoading = true;
  int _selectedIndex = 0;
  List<String> _imageUrls = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  Akun? _akun;

  @override
  void initState() {
    super.initState();
    
    _getCurrentUser();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
  try {
    setState(() {
      _isLoading = true;
    });
    final ListResult result = await FirebaseStorage.instance.ref('berita').listAll();
    final List<Reference> allFiles = result.items;

    List<String> imageUrls = [];
    for (var file in allFiles) {
      final String url = await file.getDownloadURL();
      imageUrls.add(url);
    }

    setState(() {
      _imageUrls = imageUrls;
      _isLoading = false;
    });
  } catch (error) {
    // Handle error (e.g., show a message or retry)
    setState(() {
      _isLoading = false;
    });
    print('Error fetching images: $error');
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
    case 4:
      Navigator.pushNamedAndRemoveUntil(context, '/akun_saya', ModalRoute.withName('/dashboard'));
      break;
  }
}

  void _onJualPressed() {
    Navigator.pushNamed(context, '/jual_page');
  }

  String greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi ${_akun!.nama}';
    } else if (hour < 18) {
      return 'Selamat Siang ${_akun!.nama}';
    } else {
      return 'Selamat Malam ${_akun!.nama}';
    }
  }

  String currentRoleButton(){
    if (_akun!.role == "distributor"){
      return "Ambil Sampah";
    } else if (_akun!.role == "pemilah"){
      return "Sortir Sampah";
    } else {
      return "Error Button";
    }
  }

  


  @override
  Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  
  _selectedIndex = 0;
    
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
                body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: lightgreenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        child: AutoSizeText(
                          greetingMessage(),
                          style: TextStyle(
                            fontSize: 24,
                            color: darkblueColor,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1, // Membatasi teks hanya satu baris
                          minFontSize: 10, // Ukuran font minimum yang akan digunakan
                          overflow: TextOverflow.ellipsis, // Teks yang terlalu panjang akan diakhiri dengan ...
                        ),
                      ),
                      if (_akun!.role != "user")
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: lightgreenColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          height: screenSize.height * 0.15,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_akun!.role == "distributor") {
                                if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/list_tanggal_ambil');
                              } else if (_akun!.role == "pemilah") {
                                Navigator.pushNamed(
                                    context, '/list_tanggal_pilah');
                              } else {
                                if (!context.mounted) return;
                                Navigator.pushNamed(
                                    context, '/dashboard');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkblueColor, // Warna latar belakang tombol
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              currentRoleButton(),
                              style: TextStyle(
                                fontSize: 18,
                                color: yellowColor,
                              ),
                            ),
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: lightgreenColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 20.0,
                          children: [
                            _buildCircleIconWithText(context, Icons.account_balance_wallet_rounded, "Tarik","/dalam_pengembangan"),
                            _buildCircleIconWithText(context, Icons.android_rounded, "Kosong","/dalam_pengembangan"),
                            _buildCircleIconWithText(context, Icons.book_rounded, "Petunjuk","/dalam_pengembangan"),
                            _buildCircleIconWithText(context, Icons.money_rounded, "Transfer","/dalam_pengembangan"),
                            _buildCircleIconWithText(context, Icons.android_rounded, "Kosong","/dalam_pengembangan"),
                            _buildCircleIconWithText(context, Icons.settings_rounded, "Settings","/dalam_pengembangan"),
                          ],
                        ),
                      ),
                      // Container untuk slider berita dengan gambar
                        // Cek jumlah gambar dan tampilkan sesuai kondisinya
                      if (_imageUrls.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: lightgreenColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          child: _imageUrls.length == 1
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _imageUrls[0],
                                    fit: BoxFit.cover,
                                    width: screenSize.width,
                                    height: screenSize.height * 0.2,
                                  ),
                                )
                              : CarouselSlider(
                                  options: CarouselOptions(
                                    height: screenSize.height * 0.2,
                                    autoPlay: true,
                                    enlargeCenterPage: true,
                                    aspectRatio: 16 / 9,
                                    autoPlayInterval: Duration(seconds: 3),
                                  ),
                                  items: _imageUrls.map((url) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          width: screenSize.width,
                                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                                          decoration: BoxDecoration(
                                            color: darkblueColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: lightgreenColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          height: screenSize.height * 0.15,
                          child: ElevatedButton(
                            onPressed: () {
                              
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkblueColor, // Warna latar belakang tombol
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              "Achievement",
                              style: TextStyle(
                                fontSize: 18,
                                color: yellowColor,
                              ),
                            ),
                          ),
                        ),
                      // Widget lainnya di sini
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

  
  

  Widget _buildCircleIconWithText(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: FractionallySizedBox(
        widthFactor: 1 / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: greenColor,
              ),
              child: Icon(icon, size: 30, color: darkgreenColor),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: darkblueColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}