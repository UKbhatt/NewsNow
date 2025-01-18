import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  // late final double height , width;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    final width = MediaQuery.of(context).size.width * 1;
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'images/Splashscreen.png',
            fit: BoxFit.cover,
            width: width * 0.9,
            height: height * 0.5,
          ),
          SizedBox(
            height: height * 0.1,
          ),
          Text(
            'News App',
            style: GoogleFonts.anton(letterSpacing: 0.6 , color: Colors.grey[700], fontSize: 30),
          ),
          SizedBox(
            height: height * 0.1,
          ),
          const SpinKitChasingDots(
            color: Colors.red,
            size: 50.0,
          ),
        ],
      ),
    ));
  }
}
