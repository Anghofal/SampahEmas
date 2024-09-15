import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sampah_emas/firebase_options.dart';
import 'package:sampah_emas/splash_page/splash_page.dart';
import 'package:sampah_emas/login_register/login_page.dart';

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
      '/login': (context) => LoginPage(),
      /*'/register': (context) => const RegisterPage(),
      '/dashboard': (context) => const DashboardPage(),*/
    },
  ));
}

