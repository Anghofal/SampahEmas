import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sampah_emas/distributor_page/ambil_sampah.dart';
import 'package:sampah_emas/distributor_page/distributor_list_alamat.dart';
import 'package:sampah_emas/distributor_page/distributor_list_rt.dart';
import 'package:sampah_emas/distributor_page/distributor_list_tanggal.dart';
import 'package:sampah_emas/error_page/dalam_proses.dart';
import 'package:sampah_emas/firebase_options.dart';
import 'package:sampah_emas/splash_page/splash_page.dart';
import 'package:sampah_emas/login_register/login_page.dart';
import 'package:sampah_emas/login_register/register_page.dart';
import 'package:sampah_emas/staff_page/next_sortir_sampah.dart';
import 'package:sampah_emas/staff_page/sortir_sampah.dart';
import 'package:sampah_emas/staff_page/staff_list_alamat.dart';
import 'package:sampah_emas/staff_page/staff_list_rt.dart';
import 'package:sampah_emas/staff_page/staff_list_tanggal.dart';
import 'package:sampah_emas/user_page/akun_saya.dart';
import 'package:sampah_emas/user_page/home_page.dart';
import 'package:sampah_emas/user_page/sampah_saya.dart';
import 'package:sampah_emas/user_page/detail_sampah_saya.dart';
import 'package:sampah_emas/user_page/sell_page.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  runApp(MaterialApp(
    title: 'Sampah Emas',
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashPage(),
      '/login': (context) => const LoginPage(),
      '/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const HomePage(),
      '/ambil_sampah': (context) => const AmbilSampahPage(),
      '/list_tanggal_ambil':(context) => const ListDatePage(),
      '/list_rt_ambil':(context) => const ListRtPage(),
      '/list_alamat_ambil':(context) => const ListAlamatPage(),
      '/list_tanggal_pilah':(context) => const ListDateStaffPage(),
      '/list_alamat_pilah':(context) => const ListAlamatStaffPage(),
      '/list_rt_pilah':(context) => const ListRtStaffPage(),
      '/sortir_sampah': (context) => const SortirSampahPage(),
      '/sortir_sampah_next':(context) => const SortirSampahNextPage(),
      '/dalam_pengembangan': (context) => const InDevelopment(),
      '/jual_page':(context) => const JualPage(),
      '/sampah_saya':(context) => const SampahSayaPage(),
      '/sampah_saya_detail':(context) => const SampahSayaDetailPage(),
      '/akun_saya':(context) => const AkunSayaPage(),
      
      
    },
  ));
}

