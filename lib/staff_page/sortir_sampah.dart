import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/input_widget.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/components/validators.dart';

class SortirSampahPage extends StatelessWidget {
  const SortirSampahPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SortirSampahPageFull();
  }
}

class SortirSampahPageFull extends StatefulWidget {
  const SortirSampahPageFull({super.key});
  
  

  @override
  State<StatefulWidget> createState() => _SortirSampahPageFull();

}



class _SortirSampahPageFull extends State<SortirSampahPageFull> {

  bool _isLoading = true;

  String userLaporanPath = '';
  String uid_user = '';
  String uid_pemilah = '';
  String formattedDate = '';
  String daerahKerja = '';
  String alamat_user = '';
  double berat_pemilah = 0.0;
  String sampahSaya = ''; // Inisialisasi string variable
  
  String namaSampah = ''; // Variabel untuk nama sampah dari input
  String bernilai = ''; // Variabel untuk nilai dari input
  TextEditingController namaSampahController = TextEditingController();
  TextEditingController bernilaiController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initData();
  });
  }

  Future<void> _initData() async {
  setState(() {
    _isLoading = true;
  });

  try {

    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      setState(() {
        userLaporanPath = arguments['userLaporanPath'];
        uid_user = arguments['uid_user'];
        uid_pemilah = arguments['uid_pemilah'];
        formattedDate = arguments['formattedDate'];
        daerahKerja = arguments['daerahKerja'];
        alamat_user = arguments['alamat_user'];
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

void tambahSampah() {
  // Cek jika namaSampah dan bernilai tidak kosong
  if (namaSampah.isNotEmpty && bernilai.isNotEmpty) {
    // Tambahkan namaSampah dan bernilai ke string sampahSaya
    if (sampahSaya.isEmpty) {
      sampahSaya = '$namaSampah/$bernilai'; // Jika kosong, langsung tambahkan
    } else {
      sampahSaya += '/$namaSampah/$bernilai'; // Jika sudah ada data, tambahkan dengan format yang sama
    }
    print('Sampah Saya: $sampahSaya'); // Debug print untuk melihat hasilnya
  }
}

void _removeLastItem() {
  // Pisahkan string menjadi daftar item
  List<String> items = sampahSaya.split('/');

  // Pastikan ada minimal dua item untuk dihapus
  if (items.length >= 2) {
    // Hapus dua item terakhir (namaSampah dan bernilai)
    items.removeRange(items.length - 2, items.length);

    // Gabungkan kembali menjadi string
    sampahSaya = items.join('/');

    // Update UI atau logika lainnya jika diperlukan
    setState(() {
      // Misalnya, Anda bisa menampilkan snackbar atau melakukan update lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item terakhir telah dihapus.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        ),
      );
    });
  } else {
    // Jika tidak ada cukup item untuk dihapus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tidak ada item untuk dihapus.'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
      ),
    );
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
                "Pilah Sampah Alamat\n$alamat_user",
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
            body: SafeArea(
              minimum: EdgeInsets.all(20),
              child: SingleChildScrollView(
              child: Column(
                
                children: [
                  // Input Layout Nama Sampah
                  InputLayout(
                    'Nama', 
                    TextFormField(
                      onChanged: (String value) => setState(() {
                        namaSampah = value;
                      }),
                      controller: namaSampahController,
                      validator: notEmptyValidator,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: customInputDecoration("Nama Sampah"),
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.01),
              
                  // Input Layout Bernilai
                  InputLayout(
                    'Bernilai', 
                    TextFormField(
                      onChanged: (String value) => setState(() {
                        bernilai = value;
                      }),
                      validator: notEmptyValidator,
                      controller: bernilaiController,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      decoration: customInputDecoration("Bernilai"),
                    ),
                  ),
                  
                  SizedBox(height: screenSize.height * 0.03),
              
                  // Row with plus and minus icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus Icon with circular background
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Membuat background bulat
                          color: Colors.grey[300], // Warna background
                        ),
                        child: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            // Logic for minus button
                            _removeLastItem();
                            _showSnackBarAtTop('Item terakhir yang ditambahkan telah Dihapus');
                          },
                        ),
                      ),

                      SizedBox(width: 60), // Memberikan jarak antara ikon

                      // Plus Icon with circular background
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Membuat background bulat
                          color: Colors.grey[300], // Warna background
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              tambahSampah(); // Memanggil method untuk menambah string

                              bernilaiController.clear();
                              namaSampahController.clear();

                              // Tampilkan Snackbar di atas layar
                              _showSnackBarAtTop('$namaSampah dengan nilai $bernilai telah ditambahkan');
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              
                  SizedBox(height: screenSize.height * 0.03),
              
                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: screenSize.height * 0.05,
                    child: ElevatedButton(
                      onPressed: () {
                        if (sampahSaya.isEmpty) {
                          // Jika sampahSaya kosong, tampilkan dialog konfirmasi
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text('Belum ada sampah yang dipilah. Apakah Anda yakin ingin lanjut ke halaman selanjutnya?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Menutup dialog
                                    },
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Menutup dialog
                                      Navigator.of(context).pushNamedAndRemoveUntil(
                                        '/sortir_sampah_next',
                                        ModalRoute.withName('/sortir_sampah'),
                                        arguments: {
                                          'userLaporanPath': userLaporanPath,
                                          'uid_user': uid_user,
                                          'uid_pemilah': uid_pemilah,
                                          'daerahKerja': daerahKerja,
                                          'formattedDate': formattedDate,
                                          'alamat_user': alamat_user,
                                          'sampah_saya': sampahSaya,
                                        },
                                      );
                                    },
                                    child: Text('Lanjut'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Jika sampahSaya tidak kosong, langsung navigasi
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/sortir_sampah_next',
                            ModalRoute.withName('/sortir_sampah'),
                            arguments: {
                              'userLaporanPath': userLaporanPath,
                              'uid_user': uid_user,
                              'uid_pemilah': uid_pemilah,
                              'daerahKerja': daerahKerja,
                              'formattedDate': formattedDate,
                              'alamat_user': alamat_user,
                              'sampah_saya': sampahSaya,
                            },
                          );
                        }
                      },
                      child: Text('Ajukan'),
                    ),
                  ),
              
                  SizedBox(height: screenSize.height * 0.05),
              
                  // Column for displaying sampahSaya items
                  Column(
                    children: _buildSampahList(), // Menampilkan list sampahSaya
                  ),
                ],
              ),
                        ),
            ),
    );
  }

  void _showSnackBarAtTop(String message) {
  final overlay = Overlay.of(context);
  final screenSize = MediaQuery.of(context).size;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: screenSize.height * 0.1, // Jarak dari atas layar
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

  // Method untuk membangun daftar Row dari sampahSaya
List<Widget> _buildSampahList() {
  List<Widget> rows = [];
  List<String> items = sampahSaya.split('/'); // Pisahkan string menjadi daftar
  
  for (int i = 0; i < items.length; i += 2) {
    if (i + 1 < items.length) {
      String nama = items[i];
      String nilai = items[i + 1];
      
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nama, style: TextStyle(color: Colors.white, fontSize: 16.0),), // Tampilkan nama sampah
            Text(nilai, style: TextStyle(color: Colors.white, fontSize: 16.0),), // Tampilkan nilai sampah
          ],
        ),
      );
      
      rows.add(SizedBox(height: 10)); // Menambahkan jarak antar Row
    }
  }
  
  return rows;
}
}