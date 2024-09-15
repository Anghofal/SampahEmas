import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sampah_emas/components/styles.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashFull();
  }
}

class SplashFull extends StatefulWidget {
  const SplashFull({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPage();
}

class _SplashPage extends State<SplashFull> {

@override
void initState() {
  super.initState();

  final auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    Future.delayed(const Duration(seconds: 3), () {
    
    Navigator.pushReplacementNamed(context, '/dashboard');
    });
  } else {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: darkgreenColor,
    ));


    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    // Define the width and height as a percentage of the screen size
    final double logoWidth = screenSize.width * 0.6; // 60% of screen width
    final double logoHeight = screenSize.height * 0.6; // 60% of screen height


    return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF353D2F),
          body: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget> [
                Image.asset('assets/logo/Sample Logo Sampah Emas.png',
                width: logoWidth,
                height: logoHeight,
                ),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Set the color of the loading indicator
                ),
              ],)
            ),
      ),
    );
  }
}