import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final supabase = Supabase.instance.client;
    await Future.delayed(const Duration(seconds: 3));
    final user = supabase.auth.currentUser;
    Timer(const Duration(seconds: 2), () {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/Home');
      } else {
        Navigator.pushReplacementNamed(context, '/Login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/new-3.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'News App',
                  style: GoogleFonts.anton(
                    letterSpacing: 0.6,
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: height * 0.05),
                const SpinKitChasingDots(
                  color: Colors.black,
                  size: 50.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
