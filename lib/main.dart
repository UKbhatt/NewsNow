import 'package:flutter/material.dart';
import 'package:newapp/view/loginScreen.dart';
import 'package:newapp/view/signUp.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:newapp/view/homeScreen.dart';
import './view/splashScreen.dart';
import './view/CategorySection.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: dotenv.env['ProjectURl'] ?? '',
    anonKey: dotenv.env['AnonKey'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/Home': (context) => const Homescreen(),
        '/Category': (context) => const Categorysection(),
        '/Login': (context) => const Loginscreen(),
        '/Signup': (context) => const Signup(),
      },
      title: 'News App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Splashscreen(),
    );
  }
}
