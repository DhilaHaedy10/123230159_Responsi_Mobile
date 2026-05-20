import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'detail_page.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  String _currentUserEmail = '';
  final _FavBox = Hive.box('FavBox');

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserEmail = prefs.getString('email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Anda')),
      body: _currentUserEmail.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: _FavBox.listenable(),
              builder: (context, Box box, _) {
                // 1. Ambil semua data di dalam box Hive
                final allItems = box.values.toList();
                
                // 2. Filter data: Hanya ambil data yang memiliki email user aktif saat ini
                final userItems = allItems.where((item) {
                  return item != null && item['user_email'] == _currentUserEmail;
                }).toList();

                if (userItems.isEmpty) {
                  return const Center(child: Text('Belum ada anime di favorit kamu.'));
                }

                return ListView.builder(
                  itemCount: userItems.length,
                  itemBuilder: (context, index) {
                    final anime = Map<String, dynamic>.from(userItems[index]);
                    // Menyusun key dinamis untuk proses penghapusan data
                    String compositeKey = "${_currentUserEmail}_${anime['id']}";

                    return ListTile(
                      leading: Image.network(anime['coverImageTopOffset'], width: 80, fit: BoxFit.cover),
                      title: Text(anime['canonicalTitle']),
                      subtitle: Text('${anime['ageRating']} • ${anime['episodeCount']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => box.delete(compositeKey), // Hapus menggunakan composite key
                      ),
                      onTap: () => Get.to(() => DetailPage(animeId: anime['id'])),
                    );
                  },
                );
              },
            ),
    );
  }
}
