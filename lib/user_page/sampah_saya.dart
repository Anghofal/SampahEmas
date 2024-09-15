import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/list_item.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/models/akun.dart';
import 'package:sampah_emas/models/laporan.dart';

class SampahSayaPage extends StatelessWidget {
  const SampahSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SampahSayaPageFull();
  }
}

class SampahSayaPageFull extends StatefulWidget {
  const SampahSayaPageFull({super.key});

  @override
  State<StatefulWidget> createState() => _SampahSayaPageFull();
}

class _SampahSayaPageFull extends State<SampahSayaPageFull> {

  @override
void initState() {
  super.initState();

  setState(() {
    _isLoading = true;
  });

  // Memanggil kedua method secara bersamaan dan menunggu keduanya selesai
  Future.wait([_getCurrentUser(), _getAllLaporan()]).then((_) {
    setState(() {
      _isLoading = false; // Hanya set isLoading ke false setelah kedua method selesai
    });
  }).catchError((error) {
    setState(() {
      _isLoading = false;
    });
    // Tangani error jika salah satu atau kedua Future mengalami error
    final snackbar = SnackBar(content: Text('Error: $error'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  });
}

  int _selectedIndex = 1;
  bool _isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;
  Akun? _akun;
  //Laporan? _laporan;

  List<Laporan> laporanList = [];
  
String getFormattedDateTime(int decrement) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Hitung tanggal dengan mengurangi nilai decrement
  final editedDate = today.subtract(Duration(days: decrement));

  // Format tanggal
  final formattedDate = '${editedDate.day} ${_getMonthName(editedDate.month)} ${editedDate.year}';
  
  return formattedDate;
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

int sumSampahSaya(String sampahSaya) {
  // Pecah string berdasarkan "/"
  List<String> parts = sampahSaya.split('/');

  // Ambil setiap elemen yang merupakan angka dan konversi menjadi integer
  List<int> numbers = [];
  for (int i = 1; i < parts.length; i += 2) {
    numbers.add(int.parse(parts[i]));
  }

  // Jumlahkan semua angka
  int total = numbers.reduce((a, b) => a + b);
  
  return total;
}

String modifyFormattedDateTime(DateTime dateTime) {
  final now = dateTime;
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

  Future<void> _getAllLaporan() async {
  
  try {
    
    _user = _auth.currentUser;

    if (_user != null) {
      String uid = _user!.uid;

      // Fetch the user path from the user_path collection
      DocumentSnapshot userPathSnapshot = await _db.collection('user_path').doc(uid).get();

      if (userPathSnapshot.exists) {
        String userPath = userPathSnapshot['userPath'];
        String modifiedPath = modifyUserPath(userPath);
        for (int i = -1; i <= 29; i++){
          String datePath = getFormattedDateTime(i);
          String laporanPath = '$modifiedPath/$datePath/$uid';
          //print('laporan ke -$i $laporanPath');
          // Fetch user data from the actual path
          DocumentSnapshot userSnapshot = await _db.doc(laporanPath).get();

          if (userSnapshot.exists) {
            setState(() {
              laporanList.add(Laporan.fromMap(userSnapshot.data() as Map<String, dynamic>));
            });
          } else {
            print('Laporan path not found at path: $laporanPath');  // Debug: Print if user data not found
          }

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

  String formatTimestampManual(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate(); // Konversi Timestamp ke DateTime

  // Ambil komponen tanggal dan waktu
  int day = dateTime.day;
  int month = dateTime.month;
  int year = dateTime.year;
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  // Format tanggal dan waktu secara manual
  String formattedDate = 
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${year.toString()} ' +
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  return formattedDate;
}

  Widget buildContent(Laporan laporan) {
    switch (laporan.status_laporan) {
      case 'menunggu_distributor':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: Menunggu Distributor',
              style: TextStyle(color: Colors.orange[700], fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                child: Text(
                  'Laporan Anda Telah Terupload: (${formatTimestampManual(laporan.tanggal_waktu_upload)}), sedang menunggu distributor untuk mengambil sampah.',
                  style: const TextStyle(fontSize: 14.0),
                ),
              )
            ],
          )]
        );
      case 'perjalanan_pemilah':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: Perjalanan ke Pemilah',
              style: TextStyle(color: Colors.blue[700], fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Row(
                children: [
                  const Icon(Icons.circle, color: Colors.grey, size: 12,),
                  const SizedBox(width: 8.0),
                  Expanded(
                  child: Text(
                    'Laporan Anda Telah Terupload: (${formatTimestampManual(laporan.tanggal_waktu_upload)}), sedang menunggu distributor untuk mengambil sampah.',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Sampah Anda Telah Diambil: (${formatTimestampManual(laporan.tanggal_waktu_diambil)}), sedang dalam perjalanan menuju tempat pemilahan.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berat:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${laporan.berat_distributor} gram', // Menampilkan total jumlah
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ],
        );
      case 'menunggu_dipilah':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: Menunggu Dipilah',
              style: TextStyle(color: Colors.amber[700], fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Row(
                children: [
                  const Icon(Icons.circle, color: Colors.grey, size: 12,),
                  const SizedBox(width: 8.0),
                  Expanded(
                  child: Text(
                    'Laporan Anda Telah Terupload: (${formatTimestampManual(laporan.tanggal_waktu_upload)}), sedang menunggu distributor untuk mengambil sampah.',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Sampah Anda Telah Diambil: (${formatTimestampManual(laporan.tanggal_waktu_diambil)}), sedang dalam perjalanan menuju tempat pemilahan.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
              'Sampah Anda Telah Sampai Penampung: (${formatTimestampManual(laporan.tanggal_waktu_diambil)}), sedang menunggu untuk proses pemilahan.',
              style: TextStyle(fontSize: 14.0),
            ),
                ),
              ]
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berat:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${laporan.berat_distributor} gram', // Menampilkan total jumlah
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ],
        );
      case 'sudah_dipilah':
      // Ambil string sampah_saya
      String sampahSaya = laporan.sampah_saya;
      
      // Pecah string berdasarkan "/"
      List<String> parts = sampahSaya.split('/');

      // Buat daftar widget untuk setiap pasangan teks dan angka
      List<Widget> itemList = [];
      for (int i = 0; i < parts.length; i += 2) {
        itemList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  parts[i], // Nama item sampah
                  style: const TextStyle(fontSize: 14.0),
                ),
                Text(
                  'Rp. ${parts[i + 1]}', // Jumlah item sampah
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        );
      }

      // Hitung total dari jumlah sampah
      int totalSampah = sumSampahSaya(sampahSaya);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status: Sudah Dipilah',
            style: TextStyle(color: Colors.green[700], fontSize: 14.0),
          ),
          const SizedBox(height: 8.0),
            Row(
                children: [
                  const Icon(Icons.circle, color: Colors.grey, size: 12,),
                  const SizedBox(width: 8.0),
                  Expanded(
                  child: Text(
                    'Laporan Anda Telah Terupload: (${formatTimestampManual(laporan.tanggal_waktu_upload)}), sedang menunggu distributor untuk mengambil sampah.',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'Sampah Anda Telah Diambil: (${formatTimestampManual(laporan.tanggal_waktu_diambil)}), sedang dalam perjalanan menuju tempat pemilahan.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
              'Sampah Anda Telah Sampai Penampung: (${formatTimestampManual(laporan.tanggal_waktu_diambil)}), sedang menunggu untuk proses pemilahan.',
              style: TextStyle(fontSize: 14.0),
            ),
                ),
              ]
            ),
          const SizedBox(height: 8.0),
          Row(
              children: [
                const Icon(Icons.circle, color: Colors.grey, size: 12,),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
            'Sampah yang telah berhasil dipilah: (${formatTimestampManual(laporan.tanggal_waktu_diambil)}), Berikut daftar sampah :',
            style: TextStyle(fontSize: 14.0),
          ),
                ),
              ]
          ),
          const SizedBox(height: 8.0),
          Column(
            children: itemList, // Menampilkan daftar sampah
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp. $totalSampah', // Menampilkan total jumlah
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Berat:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${laporan.berat_pemilah} gram', // Menampilkan total jumlah
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
      default:
        return const Text(
          'Status laporan tidak dikenal.',
          style: TextStyle(color: Colors.red, fontSize: 14.0),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    setState(() {
      _selectedIndex = 1;
    });
    final screenSize = MediaQuery.of(context).size;
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
                child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: laporanList.length,
                itemBuilder: (context, index) {
                  final laporan = laporanList[index];
                  return ExpandableListItem(
                    title: modifyFormattedDateTime((laporan.tanggal_waktu_upload).toDate()) ?? 'Laporan Tanpa Judul',
                    content: buildContent(laporan),
                  );
                },
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