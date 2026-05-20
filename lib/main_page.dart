import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'fav_page.dart';
import 'profile_page.dart';

/// Controller untuk mengatur state navigasi tab bawah
class NavigationController extends GetxController {
  // Variabel observable untuk melacak indeks tab yang aktif
  var currentIndex = 0.obs;

  // Daftar halaman yang akan ditampilkan sesuai urutan tab
  final List<Widget> pages = [
    const HomePage(),
    const FavPage(),
    const ProfilePage(),
  ];

  // Fungsi untuk mengubah indeks tab
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menginisialisasi NavigationController menggunakan Get.put()
    final NavigationController controller = Get.put(NavigationController());

    return Scaffold(
      // Obx digunakan untuk me-render ulang body ketika currentIndex berubah
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      
      // Menggunakan BottomNavigationBar sesuai kriteria soal
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          backgroundColor: const Color(0xFF1E1E1E), // Menyesuaikan tema gelap (dark mode)
          selectedItemColor: Colors.blue,            // Warna icon saat aktif
          unselectedItemColor: Colors.grey,          // Warna icon saat tidak aktif
          type: BottomNavigationBarType.fixed,       // Memastikan layout tab tetap proporsional
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}