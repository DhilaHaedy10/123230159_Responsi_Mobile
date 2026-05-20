import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive
  await Hive.initFlutter();
  await Hive.openBox('libraryBox'); // Box untuk menyimpan game favorit

  // Cek Sesi Login SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString('email');

  runApp(MyApp(isLoggedIn: email != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Hydra Games',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MainPage() : const LoginPage(),
    );
  }
}