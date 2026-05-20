import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DetailPage extends StatefulWidget {
  final String animeId; 
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

  void _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserEmail = prefs.getString('email') ?? '';
    });
  }

  String _getCompositeKey() => "${_currentUserEmail}_${widget.animeId}";

  bool _isInFavorite() {
    return _FavBox.containsKey(_getCompositeKey());
  }

  // Fungsi Toggle: Bisa tambah dan bisa hapus dari Detail Page menggunakan ikon Love
  void _toggleFavorite(Map<String, dynamic> animeData, Map<String, dynamic> attributes) {
    if (_currentUserEmail.isEmpty) return;

    String key = _getCompositeKey();
    setState(() {
      if (_isInFavorite()) {
        _FavBox.delete(key);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari Favorit')),
        );
      } else {
        String posterUrl = attributes['posterImage'] != null 
            ? attributes['posterImage']['small'] 
            : '';

        _FavBox.put(key, {
          'id': animeData['id'],
          'user_email': _currentUserEmail, 
          'title': attributes['canonicalTitle'] ?? 'No Title',
          'thumbnail': posterUrl,
          'averageRating': attributes['averageRating'] ?? '0.0', 
          'ageRating': attributes['ageRating'] ?? 'N/A', 
          'episodes': attributes['episodeCount']?.toString() ?? 'N/A',
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil ditambahkan ke Favorit!')),
        );
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
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          final anime = snapshot.data!;
          final attributes = anime['attributes'] ?? {};
          final isFav = _isInFavorite();

          String posterUrl = '';
          if (attributes['posterImage'] != null) {
            posterUrl = attributes['posterImage']['large'] ?? '';
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                posterUrl.isNotEmpty
                    ? Image.network(posterUrl, width: double.infinity, height: 320, fit: BoxFit.cover)
                    : Container(height: 250, color: Colors.grey[900]),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              attributes['canonicalTitle'] ?? 'No Title', 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Ikon Love untuk Tambah/Hapus dari Favorit langsung di Detail Page
                          IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () => _toggleFavorite(anime, attributes),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '⭐ ${attributes['averageRating'] ?? '0.0'}',
                        style: const TextStyle(fontSize: 18, color: Colors.amber, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: ${attributes['episodeCount'] ?? 'N/A'} Episodes',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      // Menampilkan data Age Rating (Contoh: PG-13, R, dll)
                      Text(
                        'Age Rating: ${attributes['ageRating'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      
                      // BUTTON NONTON BERSIFAT STATIC (Tidak terpengaruh status favorit)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: 
                            Text("Memutar anime ${attributes['canonicalTitle']}...")),
                            );
                          },
                          child: const Text(
                            'Nonton', 
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        attributes['synopsis'] ?? 'Tidak ada deskripsi.',
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                      ),
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