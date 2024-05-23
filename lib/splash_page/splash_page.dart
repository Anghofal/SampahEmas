import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget{
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const MaterialApp(
        home: Scaffold(
      body: Center(
        child: Text('Selamat datang di Aplikasi Sampah Emas'),
      ),
    ));
  }
  
}