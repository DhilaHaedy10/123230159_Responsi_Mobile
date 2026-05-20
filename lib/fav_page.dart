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
      appBar: AppBar(
        title: const Text('Daftar Favorit', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: _currentUserEmail.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: _FavBox.listenable(),
              builder: (context, Box box, _) {
                final allItems = box.values.toList();
                
                final userItems = allItems.where((item) {
                  return item != null && item['user_email'] == _currentUserEmail;
                }).toList();

                if (userItems.isEmpty) {
                  return const Center(child: Text('Belum ada anime favorit dimasukkan.'));
                }

                return ListView.builder(
                  itemCount: userItems.length,
                  itemBuilder: (context, index) {
                    final anime = Map<String, dynamic>.from(userItems[index]);
                    String compositeKey = "${_currentUserEmail}_${anime['id']}";

                    return ListTile(
                      leading: anime['thumbnail'] != null && anime['thumbnail'].toString().isNotEmpty
                          ? Image.network(anime['thumbnail'], width: 50, height: 70, fit: BoxFit.cover)
                          : const Icon(Icons.movie),
                      title: Text(anime['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                      // Menampilkan rating dan umur di halaman favorit
                      subtitle: Text('⭐ ${anime['averageRating'] ?? '0.0'} • ${anime['ageRating'] ?? 'N/A'}'),
                      // Tetap menyediakan opsi hapus instan melalui ikon sampah
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          box.delete(compositeKey);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Dihapus dari Favorit')),
                          );
                        },
                      ),
                      onTap: () => Get.to(() => DetailPage(animeId: anime['id'].toString())),
                    );
                  },
                );
              },
            ),
    );
  }
}