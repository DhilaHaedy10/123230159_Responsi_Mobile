import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page.dart';
import 'fav_page.dart';
import 'profile_page.dart';

class NavigationController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    const HomePage(),
    const FavPage(),
    const ProfilePage(),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.pages[controller.currentIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          backgroundColor: const Color(0xFF1E1E1E), 
          selectedItemColor: Colors.blue,            
          unselectedItemColor: Colors.grey,          
          type: BottomNavigationBarType.fixed,       
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorite', //Label disesuaikan dengan Mockup PDF
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