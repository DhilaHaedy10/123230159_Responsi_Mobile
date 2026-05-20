import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DetailPage extends StatefulWidget {
  final int animeId;
  const DetailPage({super.key, required this.animeId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _FavBox = Hive.box('FavBox');
  late Future<Map<String, dynamic>> _animeDetailFuture;
  String _currentUserEmail = '';

  @override
  void initState() {
    super.initState();
    _animeDetailFuture = ApiService.fetchAnimesDetail(widget.animeId);
    _loadCurrentUser();
  }

  // Mengambil info user yang sedang aktif login
  void _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserEmail = prefs.getString('email') ?? '';
    });
  }

  // Generate Key unik gabungan email dan id game
  String _getCompositeKey() => "${_currentUserEmail}_${widget.animeId}";

  // Cek apakah game ini ada di library milik user yang sedang aktif
  bool _isInFavorite() {
    return _FavBox.containsKey(_getCompositeKey());
  }

  void _toggleFavorite(Map<String, dynamic> anime) {
    if (_currentUserEmail.isEmpty) return;

    setState(() {
      String key = _getCompositeKey();
      if (_isInFavorite()) {
        _FavBox.delete(key);
      } else {
        // Simpan data dengan menyisipkan identitas pemilik data ('user_email')
        _FavBox.put(key, {
          'id': anime['id'],
          'user_email': _currentUserEmail, 
          'title': anime['canonicalTitle'],
          'thumbnail': anime['coverImageTopOffset'],
          'ageRating': anime['ageRating'],
          'episodes': anime['episodeCount'],
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _animeDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final anime = snapshot.data!;
          final infavorite = _isInFavorite();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'anime-${anime['id']}',
                  child: Image.network(anime['coverImageTopOffset'], width: double.infinity, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(anime['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${anime['ageRating']} • ${anime['episodeCount']}',style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      
                      // Tombol Berubah Status Sesuai Akun
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () => _toggleFavorite(anime),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isInFavorite() ? Colors.grey[800] : Colors.blue,
                          ),
                          child: Text(infavorite ? '✓ Masuk ke Favorite' : '+ Tambah Favorite', style: const TextStyle(color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(anime['synopsis'] ?? ''),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

