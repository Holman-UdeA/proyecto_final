import 'package:flutter/material.dart';
import 'package:proyecto_final/pages/home_navigation_bar_page.dart';
import 'package:proyecto_final/pages/sign_in_page.dart';
import 'package:proyecto_final/repository/firebase_api.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseApi _firebaseApi = FirebaseApi();

  @override
  void initState() {
    _closeSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage("assets/images/logo.png"),
          height: 200,
          width: 200,
        ),
      ),
    );
  }

  void _closeSplash() {
    Future.delayed(const Duration(seconds: 2), () async {
      var result = _firebaseApi.validateSession();
      if (await result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      }else{
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeNavigationBarPage()),
        );
      }
    });
  }
}
