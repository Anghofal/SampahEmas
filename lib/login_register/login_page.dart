import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sampah_emas/components/styles.dart';
import 'package:sampah_emas/components/validators.dart';
import 'package:sampah_emas/components/input_widget.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}


class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  String? email;
  String? password;

  void login() async {
  setState(() {
    _isLoading = true;
  });

  try {
    await _auth.signInWithEmailAndPassword(
        email: email!, password: password!);

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, '/dashboard', ModalRoute.withName('/dashboard'));
  } catch (e) {
    final snackbar = SnackBar(content: Text(e.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Define the width and height as a percentage of the screen size
    final double logoWidth = screenSize.width * 0.4; // 60% of screen width
    final double logoHeight = screenSize.height * 0.4; // 60% of screen height

    final double topPadding = screenSize.height * 0.2;
    
    return Scaffold(
      backgroundColor: const Color(0xFF353D2F),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
              child: Column(
                children: [                
                  Padding(
                      padding: EdgeInsets.only(top: topPadding), // Sesuaikan padding atas
                      child: AspectRatio(
                        aspectRatio: 4/1,
                        child: Center(
                          child: Image.asset(
                            'assets/logo/Sample Logo Rectangle.png',
                            width: logoWidth,
                            height: logoHeight,
                    )
                  ),
                )
              ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputLayout(
                            'Email',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                      email = value;
                                    }),
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                validator: notEmptyValidator,
                                decoration: customInputDecoration(
                                    "email@email.com"))),
                            InputLayout(
                            'Password',
                            TextFormField(
                                onChanged: (String value) => setState(() {
                                      password = value;
                                    }),
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                validator: notEmptyValidator,
                                obscureText: true,
                                decoration: customInputDecoration("....."))),
                            Container(
                            margin: EdgeInsets.only(top: 20),
                            width: double.infinity,
                            child: FilledButton(
                              style: buttonStyle,
                              child: Text('Login',
                                  style:
                                      headerStyleYellow(level: 3, dark: true)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  login();
                                }
                              }),
                            )
                        ],
                      )),
                ),
                    const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? ',
                      style: TextStyle(color: Colors.white),),
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, '/register'),
                        child: const Text('Daftar di sini',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  )
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}