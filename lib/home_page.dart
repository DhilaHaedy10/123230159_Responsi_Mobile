import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Keripikroll',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.fetchAllAnimes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data anime.'));
          }

          final animes = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // Membagi menjadi 2 kolom sesuai soal
              childAspectRatio: 0.62,     // Menyesuaikan rasio tinggi agar teks muat di bawah gambar
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: animes.length,
            itemBuilder: (context, index) {
              final anime = animes[index];
              final attributes = anime['attributes'] ?? {};
              
              String posterUrl = '';
              if (attributes['posterImage'] != null) {
                posterUrl = attributes['posterImage']['small'] ?? '';
              }

              return GestureDetector(
                onTap: () => Get.to(() => DetailPage(animeId: anime['id'].toString())),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Bagian Gambar Poster & Rating Bintang
                      Expanded(
                        child: Stack(
                          children: [
                            posterUrl.isNotEmpty
                                ? Image.network(
                                    posterUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: Colors.grey[800]),
                            // Rating Bintang di Pojok Kiri Bawah Gambar
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      attributes['averageRating'] ?? '0.0',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 2. Bagian Teks (Judul, Age Rating, dan Episode)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul Anime
                            Text(
                              attributes['canonicalTitle'] ?? 'No Title',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Menambahkan Age Rating & Episode Count di bawah judul sesuai instruksi
                            Text(
                              '${attributes['ageRating'] ?? 'N/A'} • ${attributes['episodeCount'] ?? '?' } Ep',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}