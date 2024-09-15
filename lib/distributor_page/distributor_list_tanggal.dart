import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';

class ListDatePage extends StatelessWidget {
  const ListDatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListDatePageFull();
  }
}

class ListDatePageFull extends StatefulWidget {
  const ListDatePageFull({super.key});

  @override
  State<StatefulWidget> createState() => _ListDatePageFull();
}

class _ListDatePageFull extends State<ListDatePageFull> {
  // Fungsi untuk mendapatkan tanggal dalam format yang diinginkan
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
    return Scaffold(
      backgroundColor: darkgreenColor,
      appBar: AppBar(
        title: Text('Tanggal Ambil Sampah', style: TextStyle(color: yellowColor)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: darkblueColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: 30, // Menampilkan 30 hari terakhir
          itemBuilder: (context, index) {
            String formattedDate = getFormattedDateTime(index);
            return GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/list_rt_ambil', // Nama route tujuan
                  ModalRoute.withName('/list_tanggal_ambil'), 
                  arguments: formattedDate, // Data yang dikirim ke halaman tujuan
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
                      formattedDate,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}