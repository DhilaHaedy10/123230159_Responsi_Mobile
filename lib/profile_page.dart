import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class ProfileController extends GetxController {
  var email = ''.obs;
  var totalAnimes = 0.obs;

  void loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    email.value = prefs.getString('email') ?? 'unknown@email.com';

    final box = Hive.box('libraryBox');
    // Hitung total data secara spesifik milik user aktif saja
    final userAnimes = box.values.where((item) {
      return item != null && item['user_email'] == email.value;
    });

    totalAnimes.value = userAnimes.length;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus sesi SharedPreferences
    Get.offAll(() => const LoginPage()); // redirect bersih ke login
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    controller.loadProfileData(); // Menjamin data ter-refresh setiap tab dibuka

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Text(
                  'Email: ${controller.email.value}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  'Animes Dimiliki: ${controller.totalAnimes.value}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: controller.logout,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}